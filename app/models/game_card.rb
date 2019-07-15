class GameCard < ApplicationRecord
  belongs_to :game
  belongs_to :card

  enum type: [:red, :blue, :assassin, :bystander]

  validates_presence_of :type, :chosen
  validates_numericality_of :address
end
