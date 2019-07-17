class IntelDataChannel < ApplicationCable::Channel
  def subscribed
    player = Player.includes(:game, :user).find_by(token: connection.current_player.token, role: :intel)
    if player
      stream_from "intel_#{player.game.intel_key}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
