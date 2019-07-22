class GameDataChannel < ApplicationCable::Channel
  on_subscribe :welcome_player

  def subscribed
    current_player.update(subscribed: true)
    stream_from current_player.game
    ensure_confirmation_sent
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_hint(data)
    game = current_player.game
    if game.current_player != current_player
      illegal_action("#{current_player.name} attempted to submit a hint out of turn")
    elsif !current_player.intel?
      illegal_action("#{current_player.name} attempted to submit a hint, but doesn't have the Intel role")
    elsif game.hint_invalid?(data['hintWord'])
      illegal_action("#{current_player.name} attempted to submit an invalid hint")
    else
      game.advance!

      hint = current_player.game.hints.create(
        team: current_player.team,
        word: data['hintWord'],
        num: data['numCards']
      )

      payload = {
        type: 'hint-provided',
        data: {
          isBlueTeam: hint.blue?,
          hintWord: hint.word,
          relatedCards: hint.num
        }
      }

      game.turns_remaining = relatedCards + 1
      game.save
      broadcast_message payload
    end
  end

  private

          ##  ######   #######  ##    ##
          ## ##    ## ##     ## ###   ##
          ## ##       ##     ## ####  ##
          ##  ######  ##     ## ## ## ##
    ##    ##       ## ##     ## ##  ####
    ##    ## ##    ## ##     ## ##   ###
     ######   ######   #######  ##    ##

     ######   #######  ##     ## ########   #######   ######  ######## ########   ######
    ##    ## ##     ## ###   ### ##     ## ##     ## ##    ## ##       ##     ## ##    ##
    ##       ##     ## #### #### ##     ## ##     ## ##       ##       ##     ## ##
    ##       ##     ## ## ### ## ########  ##     ##  ######  ######   ########   ######
    ##       ##     ## ##     ## ##        ##     ##       ## ##       ##   ##         ##
    ##    ## ##     ## ##     ## ##        ##     ## ##    ## ##       ##    ##  ##    ##
     ######   #######  ##     ## ##         #######   ######  ######## ##     ##  ######

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

    ##     ## ########  ######   ######     ###     ######   ########  ######
    ###   ### ##       ##    ## ##    ##   ## ##   ##    ##  ##       ##    ##
    #### #### ##       ##       ##        ##   ##  ##        ##       ##
    ## ### ## ######    ######   ######  ##     ## ##   #### ######    ######
    ##     ## ##             ##       ## ######### ##    ##  ##             ##
    ##     ## ##       ##    ## ##    ## ##     ## ##    ##  ##       ##    ##
    ##     ## ########  ######   ######  ##     ##  ######   ########  ######

    def welcome_player
      payload = {
        type: "player-joined",
        data: {
          id: current_player.id,
          name: current_player.name,
          playerRoster: compose_roster(current_player.game)
        }
      }
      broadcast_message payload
      start_game
    end

    def start_game
      game = current_player.game
      game.reload
      if all_players_in?(game)
        game.establish!

        payload = {
          type: "game-setup",
          data: {
            cards: compose_cards(game),
            players: compose_players(game),
            firstPlayerId: game.current_player.id
          }
        }
        broadcast_message payload
      end
    end

    def illegal_action(message)
      payload = {
        type: "illegal-action",
        data: {
          error: message,
          byPlayerId: current_player.id
        }
      }
      broadcast_message payload
    end

    ##     ## ######## ##       ########  ######## ########   ######
    ##     ## ##       ##       ##     ## ##       ##     ## ##    ##
    ##     ## ##       ##       ##     ## ##       ##     ## ##
    ######### ######   ##       ########  ######   ########   ######
    ##     ## ##       ##       ##        ##       ##   ##         ##
    ##     ## ##       ##       ##        ##       ##    ##  ##    ##
    ##     ## ######## ######## ##        ######## ##     ##  ######

    def broadcast_message(payload)
      ActionCable.server.broadcast_to current_player.game, message: payload.to_json
    end

    def all_players_in?(game)
      game.player_count == game.players.count{|p| p.subscribed?}
    end
end
