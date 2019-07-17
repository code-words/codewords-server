module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player

    def connect
      self.current_player = find_player
    end

    private
      def find_player
        if player = Player.find_by(token: request.path_parameters[:token])
          player
        else
          puts "Connection will be rejected for"
          p player
          reject_unauthorized_connection
        end
      end
  end
end
