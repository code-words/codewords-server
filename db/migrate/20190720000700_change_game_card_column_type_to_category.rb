class ChangeGameCardColumnTypeToCategory < ActiveRecord::Migration[5.2]
  def change
    rename_column :game_cards, :type, :category
  end
end
