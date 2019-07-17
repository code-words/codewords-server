module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player

    def connect
      self.current_player = find_player
    end

    private
      def find_player
        if player = Player.find_by(token: request.params[:token])
          player
        else
          reject_unauthorized_connection
        end
      end
  end
end
