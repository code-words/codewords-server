class RemoveIntelKeyAndGameKeyFromGame < ActiveRecord::Migration[5.2]
  def change
    remove_column :games, :intel_key
    remove_column :games, :game_key
  end
end
