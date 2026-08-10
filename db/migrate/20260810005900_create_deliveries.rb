class CreateDeliveries < ActiveRecord::Migration[7.2]
  def change
    create_table :deliveries do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.datetime :delivered_at
      t.datetime :opened_at
      t.datetime :clicked_at
      t.datetime :bounced_at
      t.datetime :unsubscribed_at

      t.timestamps
    end

    # Engagement recency per contact drives every segment on the suggestions
    # page ("cold", "lapsed", "most engaged"), so it is the hot path.
    add_index :deliveries, [ :contact_id, :opened_at ]
    add_index :deliveries, [ :campaign_id, :opened_at ]
    add_index :deliveries, [ :contact_id, :campaign_id ], unique: true
  end
end
