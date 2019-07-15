class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game

  enum role: [:spy, :intel]
  enum team: [:red, :blue]

  validates_presence_of :team, :role
end
