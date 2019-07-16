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
      render_error message: "You must provide a username"
    end
  end

  def join
    if params[:name]
      game = Game.includes(:users).find_by(invite_code: params[:invite_code])
      if game.nil?
        render_error message: "That invite code is invalid"
      elsif game.full?
        render_error message: "That game is already full"
      elsif game.username_taken? params[:name]
        render_error message: "That username is already taken"
      else
        user = User.create(name: params[:name])
        player = game.players.create(user: user)
        render status: 200, json: {
          game_channel: "game_#{game.game_key}",
          name: user.name,
          token: player.token
        }
      end
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
