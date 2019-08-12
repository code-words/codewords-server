module LobbyActions
  def select_team(data)
    current_player.reload

    if current_player.can_join_team? data["team"]
      current_player.team = data["team"]
      approve_selection
    else
      deny_selection(team: data["team"])
    end
  end

  private
    def approve_selection
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
