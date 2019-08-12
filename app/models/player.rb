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
      if role && players.count{|p| p.team == team && p.role == role} > 0
        return false, "The #{team} team already has a player with the #{role} role."
      end
    else
      return false, "The #{team} team is full."
    end
    return true, ""
  end

  def can_join_role?(role)
    players = game.players
    players_with_role = players.count{|p| p.role == role}
    if role == "intel" && players_with_role < 2
      if team && players.count{|p| p.team == team && p.role == role} > 0
        return false, "The #{team} team already has a player with the Intel role."
      end
    elsif role == "spy" && players_with_role < game.player_count - 2
      spies_per_team = (game.player_count - 2) / 2
      if team && players.count{|p| p.team == team && p.role == role} >= spies_per_team
        return false, "The #{team} team doesn't have room for more Spy players."
      end
    else
      if role == "intel"
        return false, "There are already two Intel players."
      else
        return false, "There is no more room for Spy players."
      end
    end
    return true, ""
  end

  def is_blue_team?
    if team
      blue?
    else
      nil
    end
  end

  def is_intel?
    if role
      intel?
    else
      nil
    end
  end
end
