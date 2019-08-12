class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game

  enum role: [:spy, :intel]
  enum team: [:red, :blue]

  default_scope { includes(:game, :user).order(:updated_at) }

  has_secure_token

  def name
    user.name
  end

  def can_join_team?(team)
    players = game.players
    players_on_team = players.count{|p| p.team == team}
    if players_on_team < game.player_count / 2
      if role && players.count{|p| p.team == team && p.role == role} == 0
        return false
      end
      return true
    else
      return false
    end
  end
end
