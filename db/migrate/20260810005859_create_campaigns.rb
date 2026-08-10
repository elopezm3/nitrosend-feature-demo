class CreateCampaigns < ActiveRecord::Migration[7.2]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :subject
      t.string :preheader
      t.string :status
      t.string :audience_label
      t.string :from_name
      t.string :from_email
      t.datetime :sent_at

      t.timestamps
    end

    add_index :campaigns, :sent_at
    add_index :campaigns, :status
  end
end
