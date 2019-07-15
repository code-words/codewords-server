class Game < ApplicationRecord
  has_many :players
  has_many :users, through: :players

  has_many :game_cards
  has_many :cards, through: :game_cards

  has_many :hints
  has_many :guesses
end
