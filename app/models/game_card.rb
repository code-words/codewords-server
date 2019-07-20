class GameCard < ApplicationRecord
  belongs_to :game
  belongs_to :card

  enum category: [:red, :blue, :assassin, :bystander]

  validates_presence_of :category, :chosen
  validates_numericality_of :address
end
