# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_01_095832) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_events", force: :cascade do |t|
    t.bigint "enrollment_id"
    t.bigint "user_id"
    t.string "action", null: false
    t.string "subject_type"
    t.bigint "subject_id"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.index ["action"], name: "index_activity_events_on_action"
    t.index ["enrollment_id", "occurred_at"], name: "index_activity_events_on_enrollment_id_and_occurred_at"
    t.index ["enrollment_id"], name: "index_activity_events_on_enrollment_id"
    t.index ["subject_type", "subject_id"], name: "index_activity_events_on_subject"
    t.index ["user_id"], name: "index_activity_events_on_user_id"
  end

  create_table "assessments", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "lesson_id"
    t.integer "kind", default: 0, null: false
    t.string "title", null: false
    t.text "instructions"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "kind"], name: "index_assessments_on_course_id_and_kind"
    t.index ["course_id"], name: "index_assessments_on_course_id"
    t.index ["lesson_id"], name: "index_assessments_on_lesson_id"
  end

  create_table "attempt_answers", force: :cascade do |t|
    t.bigint "attempt_id", null: false
    t.bigint "question_id", null: false
    t.bigint "choice_id"
    t.boolean "correct", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attempt_id", "question_id"], name: "index_attempt_answers_on_attempt_id_and_question_id", unique: true
    t.index ["attempt_id"], name: "index_attempt_answers_on_attempt_id"
    t.index ["choice_id"], name: "index_attempt_answers_on_choice_id"
    t.index ["question_id"], name: "index_attempt_answers_on_question_id"
  end

  create_table "attempts", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.bigint "enrollment_id", null: false
    t.datetime "submitted_at"
    t.integer "score"
    t.boolean "passed"
    t.jsonb "objective_scores", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_attempts_on_assessment_id"
    t.index ["enrollment_id"], name: "index_attempts_on_enrollment_id"
  end

  create_table "choices", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "label", null: false
    t.boolean "correct", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_choices_on_question_id"
  end

  create_table "complaints", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "course_id"
    t.string "reference", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.integer "category", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "description", null: false
    t.text "response"
    t.text "internal_note"
    t.text "improvement_action"
    t.datetime "acknowledged_at"
    t.datetime "responded_at"
    t.datetime "closed_at"
    t.bigint "handled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_complaints_on_category"
    t.index ["course_id"], name: "index_complaints_on_course_id"
    t.index ["handled_by_id"], name: "index_complaints_on_handled_by_id"
    t.index ["reference"], name: "index_complaints_on_reference", unique: true
    t.index ["user_id"], name: "index_complaints_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.string "subtitle"
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.string "category"
    t.integer "level", default: 0, null: false
    t.text "summary"
    t.text "target_audience"
    t.text "prerequisites"
    t.decimal "duration_hours", precision: 5, scale: 1
    t.text "duration_details"
    t.text "access_delay"
    t.integer "modality", default: 0, null: false
    t.text "pedagogical_methods"
    t.text "evaluation_methods"
    t.text "accessibility"
    t.integer "price_cents"
    t.text "pricing_details"
    t.text "funding_options"
    t.string "recognition", default: "Attestation de fin de formation (formation non certifiante)", null: false
    t.text "digital_requirements"
    t.text "support_details"
    t.string "contact_email"
    t.datetime "info_updated_at"
    t.bigint "trainer_id"
    t.bigint "pedagogical_referent_id"
    t.integer "pass_threshold", default: 70, null: false
    t.integer "positioning_threshold", default: 50, null: false
    t.integer "inactivity_reminder_days", default: 7, null: false
    t.integer "inactivity_alert_days", default: 14, null: false
    t.datetime "published_at"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pedagogical_referent_id"], name: "index_courses_on_pedagogical_referent_id"
    t.index ["slug"], name: "index_courses_on_slug", unique: true
    t.index ["status"], name: "index_courses_on_status"
    t.index ["trainer_id"], name: "index_courses_on_trainer_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "funding_type", default: 0, null: false
    t.string "employer_name"
    t.string "employer_contact"
    t.text "employer_objectives"
    t.string "convention_reference"
    t.datetime "requested_at"
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.text "admin_note"
    t.text "needs_synthesis"
    t.datetime "needs_reviewed_at"
    t.bigint "needs_reviewed_by_id"
    t.datetime "welcome_acknowledged_at"
    t.integer "positioning_decision"
    t.text "positioning_note"
    t.datetime "positioning_decided_at"
    t.datetime "started_at"
    t.datetime "last_activity_at"
    t.datetime "completed_at"
    t.datetime "abandoned_at"
    t.text "abandon_reason"
    t.datetime "certificate_issued_at"
    t.string "certificate_number"
    t.datetime "cold_survey_sent_at"
    t.boolean "legacy", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_enrollments_on_approved_by_id"
    t.index ["certificate_number"], name: "index_enrollments_on_certificate_number", unique: true
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["needs_reviewed_by_id"], name: "index_enrollments_on_needs_reviewed_by_id"
    t.index ["status"], name: "index_enrollments_on_status"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "lesson_objectives", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.bigint "objective_id", null: false
    t.index ["lesson_id", "objective_id"], name: "index_lesson_objectives_on_lesson_id_and_objective_id", unique: true
    t.index ["lesson_id"], name: "index_lesson_objectives_on_lesson_id"
    t.index ["objective_id"], name: "index_lesson_objectives_on_objective_id"
  end

  create_table "lesson_progresses", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.bigint "lesson_id", null: false
    t.datetime "first_viewed_at"
    t.datetime "last_viewed_at"
    t.datetime "completed_at"
    t.integer "active_seconds", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id", "lesson_id"], name: "index_lesson_progresses_on_enrollment_id_and_lesson_id", unique: true
    t.index ["enrollment_id"], name: "index_lesson_progresses_on_enrollment_id"
    t.index ["lesson_id"], name: "index_lesson_progresses_on_lesson_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "title", null: false
    t.text "summary"
    t.integer "position", default: 0, null: false
    t.integer "estimated_minutes", default: 15, null: false
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "position"], name: "index_lessons_on_course_id_and_position"
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "needs_assessments", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.string "job_title", null: false
    t.text "work_situations", null: false
    t.text "expectations", null: false
    t.text "prior_experience"
    t.text "questions"
    t.boolean "accommodation_contact_requested", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_needs_assessments_on_enrollment_id", unique: true
  end

  create_table "objectives", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.integer "position", default: 0, null: false
    t.text "description", null: false
    t.text "success_criterion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_objectives_on_course_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.bigint "objective_id"
    t.text "prompt", null: false
    t.text "explanation"
    t.integer "position", default: 0, null: false
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_questions_on_assessment_id"
    t.index ["objective_id"], name: "index_questions_on_objective_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.integer "kind", default: 0, null: false
    t.bigint "sent_by_id"
    t.text "message"
    t.datetime "sent_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_reminders_on_enrollment_id"
    t.index ["sent_by_id"], name: "index_reminders_on_sent_by_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_batch_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.index ["batch_id"], name: "index_solid_queue_batch_executions_on_batch_id"
    t.index ["job_id"], name: "index_solid_queue_batch_executions_on_job_id", unique: true
  end

  create_table "solid_queue_batches", force: :cascade do |t|
    t.string "active_job_batch_id"
    t.string "description"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_failure"
    t.text "metadata"
    t.integer "total_jobs", default: 0, null: false
    t.integer "completed_jobs", default: 0, null: false
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "failed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_batch_id"], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
    t.index ["finished_at"], name: "index_solid_queue_batches_on_finished_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "batch_id"
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["batch_id"], name: "index_solid_queue_jobs_on_batch_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "support_messages", force: :cascade do |t|
    t.bigint "support_thread_id", null: false
    t.bigint "author_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_support_messages_on_author_id"
    t.index ["support_thread_id"], name: "index_support_messages_on_support_thread_id"
  end

  create_table "support_threads", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "enrollment_id"
    t.bigint "lesson_id"
    t.integer "category", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "subject", null: false
    t.datetime "first_response_at"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_support_threads_on_enrollment_id"
    t.index ["lesson_id"], name: "index_support_threads_on_lesson_id"
    t.index ["status"], name: "index_support_threads_on_status"
    t.index ["user_id"], name: "index_support_threads_on_user_id"
  end

  create_table "survey_responses", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.integer "kind", default: 0, null: false
    t.integer "overall_rating", null: false
    t.integer "content_rating"
    t.integer "support_rating"
    t.integer "platform_rating"
    t.integer "objectives_rating"
    t.integer "recommend_score"
    t.text "applied_in_practice"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id", "kind"], name: "index_survey_responses_on_enrollment_id_and_kind", unique: true
    t.index ["enrollment_id"], name: "index_survey_responses_on_enrollment_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "role", default: 0, null: false
    t.string "job_title"
    t.string "organization_name"
    t.integer "organization_type"
    t.string "phone"
    t.text "bio"
    t.datetime "terms_accepted_at"
    t.boolean "reports_referent", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_events", "enrollments"
  add_foreign_key "activity_events", "users"
  add_foreign_key "assessments", "courses"
  add_foreign_key "assessments", "lessons"
  add_foreign_key "attempt_answers", "attempts"
  add_foreign_key "attempt_answers", "choices"
  add_foreign_key "attempt_answers", "questions"
  add_foreign_key "attempts", "assessments"
  add_foreign_key "attempts", "enrollments"
  add_foreign_key "choices", "questions"
  add_foreign_key "complaints", "courses"
  add_foreign_key "complaints", "users"
  add_foreign_key "complaints", "users", column: "handled_by_id"
  add_foreign_key "courses", "users", column: "pedagogical_referent_id"
  add_foreign_key "courses", "users", column: "trainer_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "enrollments", "users", column: "approved_by_id"
  add_foreign_key "enrollments", "users", column: "needs_reviewed_by_id"
  add_foreign_key "lesson_objectives", "lessons"
  add_foreign_key "lesson_objectives", "objectives"
  add_foreign_key "lesson_progresses", "enrollments"
  add_foreign_key "lesson_progresses", "lessons"
  add_foreign_key "lessons", "courses"
  add_foreign_key "needs_assessments", "enrollments"
  add_foreign_key "objectives", "courses"
  add_foreign_key "questions", "assessments"
  add_foreign_key "questions", "objectives"
  add_foreign_key "reminders", "enrollments"
  add_foreign_key "reminders", "users", column: "sent_by_id"
  add_foreign_key "solid_queue_batch_executions", "solid_queue_batches", column: "batch_id", on_delete: :cascade
  add_foreign_key "solid_queue_batch_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "support_messages", "support_threads"
  add_foreign_key "support_messages", "users", column: "author_id"
  add_foreign_key "support_threads", "enrollments"
  add_foreign_key "support_threads", "lessons"
  add_foreign_key "support_threads", "users"
  add_foreign_key "survey_responses", "enrollments"
end
