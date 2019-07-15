class Hint < ApplicationRecord
  belongs_to :game

  enum team: [:red, :blue]

  validates_presence_of :word, :team
  validates_numericality_of :num
end
