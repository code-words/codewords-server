class IntelDataChannel < ApplicationCable::Channel
  def subscribed
    player = Player.includes(:game, :user).find_by(token: params[:token])
    if player&.role == "intel"
      stream_from "intel_#{player.game.intel_key}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
