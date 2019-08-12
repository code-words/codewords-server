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
      spies_per_team = (game.player_count - 2) / 2
      if role == "intel" && collision_count(team, role) > 0
        return false, "The #{team} team already has a player with the Intel role."
      elsif role == "spy" && collision_count(team, role) >= spies_per_team
        return false, "The #{team} team doesn't have room for more Spy players."
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
      if team && collision_count(team, role) > 0
        return false, "The #{team} team already has a player with the Intel role."
      end
    elsif role == "spy" && players_with_role < game.player_count - 2
      spies_per_team = (game.player_count - 2) / 2
      if team && collision_count(team, role) >= spies_per_team
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

  private
    def collision_count(team, role)
      players = game.players
      players.count do |player|
        player.team == team && player.role == role
      end
    end

    def err(snip = nil)
      {
        team_full: "The #{snip} team is full.",
        team_intel_full: "The #{snip} team already has a player with the Intel role.",
        team_spies_full: "The #{snip} team doesn't have room for more Spy players.",
        intel_full: "There are already two Intel players.",
        spies_full: "There is no more room for Spy players.",
        game_started: "Unable to change #{snip}. The game has already begun."
      }
    end
end
