class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game

  enum role: [:spy, :intel]
  enum team: [:red, :blue]

  has_secure_token

  def name
    user.name
  end
end
