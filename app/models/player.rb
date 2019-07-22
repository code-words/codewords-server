class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game

  enum role: [:spy, :intel]
  enum team: [:red, :blue]

  default_scope { order(:updated_at) }

  has_secure_token

  def name
    user.name
  end
end
