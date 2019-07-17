module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player

    def connect
      self.current_player = find_player
    end

    private
      def find_player
        #because there's no way to test the path_parameters
        token = request.path_parameters[:token] || request.params[:token]
        if player = Player.find_by(token: token)
          player
        else
          reject_unauthorized_connection
        end
      end
  end
end
