class GameDataChannel < ApplicationCable::Channel
  on_subscribe :welcome_player, :start_game

  def subscribed
    # ActionCable doesn't give access to params[] here if mounted in application.rb
    @player = Player.includes(:game, :user).find_by(token: connection.current_player.token)
    @player.update(subscribed: true)
    stream_from "game_#{@player.game.game_key}"
    ensure_confirmation_sent
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private
    def compose_roster(game)
      game.players.map do |p|
        {
          id: p.id,
          name: p.name
        }
      end
    end

    def compose_players(game)
      game.players.map do |p|
        {
          id: p.id,
          name: p.name,
          isBlueTeam: p.blue?,
          isIntel: p.intel?
        }
      end
    end

    def compose_cards(game)
      cards = game.game_cards.sort_by &:address
      cards.map do |c|
        {
          id: c.id,
          word: c.word
        }
      end
    end

    def welcome_player
      broadcast_message = {
        type: "player-joined",
        data: {
          id: @player.id,
          name: @player.name,
          playerRoster: compose_roster(@player.game)
        }
      }
      ActionCable.server.broadcast "game_#{@player.game.game_key}", message: broadcast_message.to_json
    end

    def start_game
      game = @player.game
      game.reload
      if all_players_in?(game)
        game.establish!

        broadcast_message = {
          type: "game-setup",
          data: {
            cards: compose_cards(game),
            players: compose_players(game),
            firstTeam: game.blue_first? ? :blue : :red
          }
        }
        ActionCable.server.broadcast "game_#{@player.game.game_key}", message: broadcast_message.to_json
      end
    end

    def all_players_in?(game)
      game.player_count == game.players.count{|p| p.subscribed?}
    end
end
