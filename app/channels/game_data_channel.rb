class GameDataChannel < ApplicationCable::Channel
  def subscribed
    player = Player.includes(:game, :user).find_by(token: connection.current_player.token)
    stream_from "game_#{player.game.game_key}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
