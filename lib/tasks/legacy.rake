# Reprise des données de l'ancienne application (Rails 6, base Heroku).
#
#   LEGACY_DATABASE_URL=postgres://… bin/rails legacy:import
#   LEGACY_DATABASE_URL=postgres://… LEGACY_STORAGE_PATH=/chemin/vers/ancien/storage bin/rails legacy:import
#
# Reprend : utilisateurs (mots de passe conservés), administrateurs, ateliers -> formations (en brouillon),
# leçons et leur contenu riche, QCM -> évaluation finale, inscriptions, chapitres terminés, réponses.
# Les fichiers (vidéos, images) ne sont repris que si LEGACY_STORAGE_PATH pointe vers l'ancien dossier storage/.
# Idempotent : chaque objet repris garde son identifiant d'origine (legacy_id) et n'est pas recréé.
namespace :legacy do
  desc "Importer les données de l'ancienne plateforme copas-mooc"
  task import: :environment do
    url = ENV.fetch("LEGACY_DATABASE_URL") { abort "Définissez LEGACY_DATABASE_URL" }
    Legacy::Record.establish_connection(url)
    conn = Legacy::Record.connection
    rows = ->(sql) { conn.select_all(sql).to_a }
    storage = ENV["LEGACY_STORAGE_PATH"].presence

    attach = lambda do |record, name, legacy_type, legacy_id|
      next unless storage

      rows.("SELECT b.key, b.filename, b.content_type FROM active_storage_attachments a JOIN active_storage_blobs b ON b.id = a.blob_id " \
            "WHERE a.record_type = #{conn.quote(legacy_type)} AND a.record_id = #{legacy_id.to_i} AND a.name = #{conn.quote(name)}").each do |blob|
        path = File.join(storage, blob["key"][0, 2], blob["key"][2, 2], blob["key"])
        if File.exist?(path)
          record.public_send(name == "photo" && record.is_a?(Course) ? "cover" : (name == "photo" ? "avatar" : name))
                .attach(io: File.open(path), filename: blob["filename"], content_type: blob["content_type"])
        else
          puts "  fichier absent : #{blob['filename']}"
        end
      end
    end

    rich = ->(type, id) { rows.("SELECT body FROM action_text_rich_texts WHERE record_type = #{conn.quote(type)} AND record_id = #{id.to_i} LIMIT 1").first&.dig("body") }

    users = {}
    puts "Utilisateurs…"
    rows.("SELECT * FROM users ORDER BY id").each do |r|
      user = User.find_by(legacy_id: r["id"]) || User.find_by(email: r["email"].downcase)
      unless user
        user = User.new(first_name: r["first_name"].presence || "?", last_name: r["last_name"].presence || "?", email: r["email"],
                        bio: r["description"], legacy_id: r["id"], terms_accepted_at: r["created_at"],
                        confirmed_at: r["confirmed_at"] || r["created_at"], created_at: r["created_at"])
        user.encrypted_password = r["encrypted_password"]
        user.save!(validate: false)
        attach.(user, "photo", "User", r["id"])
      end
      users[r["id"]] = user
    end

    puts "Administrateurs…"
    rows.("SELECT * FROM admins ORDER BY id").each do |r|
      user = User.find_by(email: r["email"].downcase)
      if user
        user.update_columns(role: User.roles[:admin])
      else
        user = User.new(first_name: "Admin", last_name: r["email"].split("@").first, email: r["email"], role: :admin,
                        terms_accepted_at: Time.current, confirmed_at: Time.current)
        user.encrypted_password = r["encrypted_password"]
        user.save!(validate: false)
      end
    end

    courses = {}
    lessons = {}
    puts "Formations…"
    rows.("SELECT * FROM workshops ORDER BY id").each do |r|
      course = Course.find_by(legacy_id: r["id"]) || Course.new(legacy_id: r["id"])
      if course.new_record?
        course.assign_attributes(title: r["title"], subtitle: r["subtitle"], category: r["category"], status: :draft,
                                 summary: r["description"], prerequisites: r["requirements"], trainer: users[r["user_id"]],
                                 price: r["cost"], description: rich.("Workshop", r["id"]),
                                 slug: (r["slug"].presence || r["title"].to_s).parameterize.presence || "formation-#{r['id']}")
        course.slug = "#{course.slug}-#{r['id']}" if Course.exists?(slug: course.slug)
        course.save!
        attach.(course, "photo", "Workshop", r["id"])
        # Les anciens « résultats attendus » deviennent des objectifs à reformuler et à critériser.
        r["outcomes"].to_s.split(/\r?\n/).map(&:strip).reject(&:blank?).each_with_index do |line, i|
          course.objectives.create!(position: i + 1, description: line.sub(/\A[-*•]\s*/, ""))
        end
      end
      courses[r["id"]] = course

      rows.("SELECT * FROM lessons WHERE workshop_id = #{r['id'].to_i} ORDER BY \"order\" NULLS LAST, id").each_with_index do |l, i|
        lesson = Lesson.find_by(legacy_id: l["id"]) || course.lessons.create!(
          title: l["title"].to_s.truncate(120), summary: l["description"], position: i + 1, legacy_id: l["id"],
          content: rich.("Lesson", l["id"])
        )
        attach.(lesson, "video", "Lesson", l["id"]) if lesson.previously_new_record?
        lessons[l["id"]] = lesson
      end

      questions = rows.("SELECT * FROM questions WHERE workshop_id = #{r['id'].to_i} ORDER BY id")
      next if questions.empty?

      final = course.final_assessment || course.assessments.create!(kind: :final, title: "Évaluation finale des acquis")
      questions.each do |q|
        next if Question.exists?(legacy_id: q["id"])

        choices = [ [ q["answer"], true ], [ q["distractor_1"], false ], [ q["distractor_2"], false ], [ q["distractor_3"], false ] ]
                  .reject { |label, _| label.blank? }
        question = final.questions.new(prompt: q["question"], legacy_id: q["id"],
                                       choices_attributes: choices.each_with_index.map { |(label, ok), i| { label: label, correct: ok, position: i + 1 } })
        question.save!(validate: choices.size >= 2)
      end
    end

    puts "Inscriptions…"
    rows.("SELECT * FROM enrollments ORDER BY id").each do |r|
      user = users[r["user_id"]]
      course = courses[r["workshop_id"]]
      next unless user && course

      enrollment = Enrollment.find_or_initialize_by(user: user, course: course)
      next if enrollment.persisted?

      enrollment.assign_attributes(status: :active, legacy: true, funding_type: :self_funded, requested_at: r["created_at"],
                                   approved_at: r["created_at"], started_at: r["created_at"], last_activity_at: r["updated_at"],
                                   positioning_decision: :direct_access, welcome_acknowledged_at: r["created_at"],
                                   positioning_note: "Inscription reprise de l'ancienne plateforme.")
      enrollment.save!(validate: false)
      enrollment.log!("enrollment.started", metadata: { legacy: true })

      rows.("SELECT * FROM completes WHERE user_id = #{r['user_id'].to_i} AND completed_type = 'Lesson'").each do |c|
        lesson = lessons[c["completed_id"]]
        next unless lesson && lesson.course_id == course.id

        enrollment.lesson_progresses.find_or_create_by!(lesson: lesson) { |p| p.first_viewed_at = c["created_at"]; p.completed_at = c["created_at"] }
      end

      final = course.final_assessment
      answers = rows.("SELECT * FROM answers WHERE user_id = #{r['user_id'].to_i} AND workshop_id = #{r['workshop_id'].to_i}")
      next unless final && answers.any?

      attempt = enrollment.attempts.create!(assessment: final)
      answers.each do |a|
        question = Question.find_by(legacy_id: a["question_id"])
        next unless question

        choice = question.choices.find_by(label: a["user_answer"])
        attempt.attempt_answers.create!(question: question, choice: choice, correct: choice&.correct? || false)
      end
      total = attempt.attempt_answers.count
      score = total.zero? ? 0 : (attempt.attempt_answers.where(correct: true).count * 100.0 / total).round
      attempt.update!(score: score, passed: score >= course.pass_threshold, submitted_at: answers.map { _1["created_at"] }.max)
    end

    puts "Terminé : #{users.size} utilisateurs, #{courses.size} formations (en brouillon : complétez leurs fiches avant publication)."
  end
end

module Legacy
  class Record < ActiveRecord::Base
    self.abstract_class = true
  end
end
