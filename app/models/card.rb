class Card < ApplicationRecord
  validates :word, presence: true

  has_many :game_cards
  has_many :games, through: :game_cards
end
