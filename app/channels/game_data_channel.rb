class GameDataChannel < ApplicationCable::Channel
  def subscribed
    player = Player.includes(:game, :user).find_by(token: connection.current_player.token)
    puts "Subscription attempted by"
    p player
    if player
      stream_from "game_#{player.game.game_key}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
