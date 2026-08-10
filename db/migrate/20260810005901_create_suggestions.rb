class CreateSuggestions < ActiveRecord::Migration[7.2]
  def change
    create_table :suggestions do |t|
      t.string :category
      t.string :title
      t.text :headline_fact
      t.text :why_now
      t.string :proposed_subject
      t.text :proposed_angle
      t.string :segment_key
      t.integer :estimated_reach
      t.string :confidence
      t.string :status
      t.datetime :generated_at

      t.timestamps
    end

    add_index :suggestions, [ :category, :status ]
  end
end
