class MigrateBodytoRichBodyLessons < ActiveRecord::Migration[6.0]
  def up
    Lesson.find_each do |lesson|
      lesson.update(rich_body: lesson.description)
    end
  end
end
