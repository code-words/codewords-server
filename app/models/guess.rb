class Guess < ApplicationRecord
  belongs_to :game
  belongs_to :game_card

  enum team: [:red, :blue]

  validates_presence_of :team
end
