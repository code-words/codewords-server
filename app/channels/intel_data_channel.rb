class IntelDataChannel < ApplicationCable::Channel
  def subscribed
    player = Player.includes(:game, :user).find_by(token: params[:token])
    if player&.role == "intel"
      stream_from "intel_#{player.game.intel_key}"
    else
      reject
    end
  end
  
  def hint(data)
    puts data
    message = Message.create(body: data['message'])
    socket = { message: message.body }
    ChatChannel.broadcast_to('GameDataChannel', socket)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
