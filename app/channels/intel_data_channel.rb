class IntelDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "intel_data_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
