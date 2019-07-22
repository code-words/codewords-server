class AddCurrentPlayerToGame < ActiveRecord::Migration[5.2]
  def change
    add_reference :games, :current_player, foreign_key: {to_table: :players}
  end
end
