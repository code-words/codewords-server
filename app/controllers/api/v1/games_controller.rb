class Api::V1::GamesController < Api::V1::ApiController
  def create
    if params[:name]
      user = User.create(name: params[:name])
      game = Game.create()
      player = game.players.create(user: user)
      render status: 201, json: {
        game_channel: "game_#{game.game_key}",
        invite_code: game.invite_code,
        name: user.name,
        token: player.token
      }
    elsif
      render status: 401, json: {
        error: "You must provide a username"
      }
  end

  def join
    if params[:name]
    else
      render_error message: "You must provide a username"
    end
  end

  private
    def render_error status: 401, message: "Unauthorized"
      render status: status, json: {
        error: message
      }
    end
end
