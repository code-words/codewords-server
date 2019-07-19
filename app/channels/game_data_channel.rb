class GameDataChannel < ApplicationCable::Channel
  on_subscribe :welcome_player

  def subscribed
    # ActionCable doesn't give access to params[] here if mounted in application.rb
    @player = Player.includes(:game, :user).find_by(token: connection.current_player.token)
    stream_from "game_#{@player.game.game_key}"
    ensure_confirmation_sent
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private
    def compose_players(game)
      game.players.map do |player|
        {
          id: player.id,
          name: player.name
        }
      end
    end

    def welcome_player
      broadcast_message = {
        type: "player-joined",
        data: {
          id: @player.id,
          name: @player.name,
          playerRoster: compose_players(@player.game)
        }
      }
      ActionCable.server.broadcast "game_#{@player.game.game_key}", message: broadcast_message.to_json
    end
end
