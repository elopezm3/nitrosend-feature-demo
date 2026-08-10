class AddSourceSuggestionToCampaigns < ActiveRecord::Migration[7.2]
  def change
    add_column :campaigns, :source_suggestion_id, :integer
  end
end
