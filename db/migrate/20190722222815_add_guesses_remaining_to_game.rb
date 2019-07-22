class AddGuessesRemainingToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :guesses_remaining, :integer
  end
end
