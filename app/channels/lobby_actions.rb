module LobbyActions
  def select_team(data)
    current_player.reload

    if current_player.can_join_team? data["team"]
      current_player.team = data["team"]
      approve_selection(team: data["team"])
    else
      deny_selection(team: data["team"])
    end
  end

  def select_role(data)
    current_player.reload

    if current_player.can_join_role? data["role"]
      current_player.role = data["role"]
      approve_selection(role: data["role"])
    else
      deny_selection(role: data["role"])
    end
  end

  private
    def approve_selection(team: nil, role: nil)
      current_player.save
      payload = {
        type: "player-update",
        data: {
          id: current_player.id,
          name: current_player.name,
          isBlueTeam: current_player.is_blue_team?,
          isIntel: current_player.is_intel?,
          playerRoster: compose_roster(current_player.game)
        }
      }
      broadcast_message payload
    end
end
