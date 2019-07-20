class AddPlayerCountToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :player_count, :integer, default: 4
  end
end
