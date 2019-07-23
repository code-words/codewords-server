class GameCard < ApplicationRecord
  belongs_to :game
  belongs_to :card

  enum category: [:red, :blue, :assassin, :bystander]

  validates_presence_of :category
  validates :chosen, inclusion: {in: [true, false]}
  validates_numericality_of :address

  default_scope { includes(:card).order(:address) }

  def word
    card.word
  end
end
