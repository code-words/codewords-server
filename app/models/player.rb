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
    return false, err("team")[:game_started] if game.started?
    players = game.players
    players_on_team = players.count{|p| p.team == team}
    if players_on_team < game.player_count / 2
      spies_per_team = (game.player_count - 2) / 2
      if role == "intel" && collision_count(team, role) > 0
        return false, err(team)[:team_intel_full]
      elsif role == "spy" && collision_count(team, role) >= spies_per_team
        return false, err(team)[:team_spies_full]
      end
    else
      return false, err(team)[:team_full]
    end
    return true, ""
  end

  def can_join_role?(role)
    return false, err("role")[:game_started] if game.started?
    players = game.players
    players_with_role = players.count{|p| p.role == role}
    if role == "intel" && players_with_role < 2
      if team && collision_count(team, role) > 0
        return false, err(team)[:team_intel_full]
      end
    elsif role == "spy" && players_with_role < game.player_count - 2
      spies_per_team = (game.player_count - 2) / 2
      if team && collision_count(team, role) >= spies_per_team
        return false, err(team)[:team_spies_full]
      end
    else
      if role == "intel"
        return false, err[:intel_full]
      else
        return false, err[:spies_full]
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
