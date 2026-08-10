class AddVariantToSuggestions < ActiveRecord::Migration[7.2]
  def change
    add_column :suggestions, :variant, :integer, default: 0, null: false
    add_index :suggestions, [ :category, :variant ], unique: true
  end
end
