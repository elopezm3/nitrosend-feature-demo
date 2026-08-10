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

ActiveRecord::Schema[7.2].define(version: 2026_08_10_005901) do
  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.string "subject"
    t.string "preheader"
    t.string "status"
    t.string "audience_label"
    t.string "from_name"
    t.string "from_email"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sent_at"], name: "index_campaigns_on_sent_at"
    t.index ["status"], name: "index_campaigns_on_status"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "source"
    t.string "status"
    t.datetime "subscribed_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_contacts_on_email", unique: true
  end

  create_table "deliveries", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "contact_id", null: false
    t.datetime "delivered_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.datetime "bounced_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "opened_at"], name: "index_deliveries_on_campaign_id_and_opened_at"
    t.index ["campaign_id"], name: "index_deliveries_on_campaign_id"
    t.index ["contact_id", "campaign_id"], name: "index_deliveries_on_contact_id_and_campaign_id", unique: true
    t.index ["contact_id", "opened_at"], name: "index_deliveries_on_contact_id_and_opened_at"
    t.index ["contact_id"], name: "index_deliveries_on_contact_id"
  end

  create_table "suggestions", force: :cascade do |t|
    t.string "category"
    t.string "title"
    t.text "headline_fact"
    t.text "why_now"
    t.string "proposed_subject"
    t.text "proposed_angle"
    t.string "segment_key"
    t.integer "estimated_reach"
    t.string "confidence"
    t.string "status"
    t.datetime "generated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "status"], name: "index_suggestions_on_category_and_status"
  end

  add_foreign_key "deliveries", "campaigns"
  add_foreign_key "deliveries", "contacts"
end
