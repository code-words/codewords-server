class Api::V1::IntelController < Api::V1::ApiController
  def show
    if params[:token]
      player = Player.includes(:user, :game).find_by(token: params[:token])
      if player&.intel?
        render json: {
          cards: serialize_cards(player.game)
        }
      elsif player
        render_error message: "You are not authorized for this game's secret intel"
      else
        render_error message: "Unable to find a user with that token"
      end
    else
      render_error message: "You must provide your access token"
    end
  end

  private
    def render_error status: 401, message: "Unauthorized"
      render status: status, json: {
        error: message
      }
    end

    def serialize_cards(game)
      game.game_cards.map do |card|
        {
          id: card.id,
          type: card.category
        }
      end
    end
end
