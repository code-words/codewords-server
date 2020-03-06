class GameDataChannel < ApplicationCable::Channel
  include LobbyActions
  on_subscribe :welcome_player

  def subscribed
    current_player.update(subscribed: true)
    if current_player.game.over?
      reject
    else
      ensure_confirmation_sent
      stream_for current_player.game
    end
  end

  def unsubscribed
    current_player.update(subscribed: false)
  end

  def send_hint(hint)
    current_player.reload
    game = current_player.game
    if game.current_player != current_player
      illegal_action("#{current_player.name} attempted to submit a hint out of turn")
    elsif !current_player.intel?
      illegal_action("#{current_player.name} attempted to submit a hint, but doesn't have the Intel role")
    elsif game.hint_invalid?(hint["hintWord"])
      illegal_action("#{current_player.name} attempted to submit an invalid hint")
    else
      game.advance!

      saved_hint = game.hints.create(
        team: current_player.team,
        word: hint["hintWord"],
        num: hint["numCards"].to_i
      )

      game.guesses_remaining = saved_hint.num + 1
      game.save
      provide_hint saved_hint
    end
  end

  def send_guess(card)
    current_player.reload
    game = current_player.game
    if game.current_player != current_player
      illegal_action("#{current_player.name} attempted to submit a guess out of turn")
    elsif !current_player.spy?
      illegal_action("#{current_player.name} attempted to submit a guess, but doesn't have the Spy role")
    elsif !game.includes_card?(card["id"])
      illegal_action("#{current_player.name} attempted to submit a guess for a card not in this game")
    else
      contents = game.process_guess(card["id"])
      if game.over?
        game.save
        game_over contents
      else
        board_update contents
      end
    end
  end

  def start_game
    game = current_player.game
    game.reload
    if all_players_in?(game) && game.game_cards.count == 0
      game.establish!
      game_setup
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

    def compose_players(game)
      game.players.map do |p|
        {
          id: p.id,
          name: p.name,
          isBlueTeam: p.is_blue_team?,
          isIntel: p.is_intel?
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

    def compose_card(card)
      if card
        return {
          id: card.id,
          flipped: card.chosen,
          type: card.category
        }
      else
        return nil
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
          isBlueTeam: current_player.is_blue_team?,
          isIntel: current_player.is_intel?,
          playerRoster: compose_players(current_player.game)
        }
      }
      broadcast_message payload
    end

    def game_setup
      game = current_player.game
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

    def provide_hint(hint)
      game = current_player.game
      payload = {
        type: 'hint-provided',
        data: {
          isBlueTeam: hint.blue?,
          hintWord: hint.word,
          relatedCards: hint.num,
          currentPlayerId: game.current_player.id
        }
      }
      broadcast_message payload
    end

    def board_update(details)
      card = compose_card details[:card]
      payload = {
        type: "board-update",
        data: {
          card: card,
          remainingAttempts: details[:remainingAttempts],
          currentPlayerId: details[:currentPlayer].id
        }
      }
      broadcast_message payload
    end

    def game_over(details)
      payload = {
        type: "game-over",
        data: {
          card: {
            id: details[:card].id,
            flipped: details[:card].chosen,
            type: details[:card].category
          },
          winningTeam: details[:winningTeam],
          nextGame: details[:nextGame]
        }
      }
      broadcast_message payload
      disconnect_all_players(current_player.game)
    end

    ##     ## ######## ##       ########  ######## ########   ######
    ##     ## ##       ##       ##     ## ##       ##     ## ##    ##
    ##     ## ##       ##       ##     ## ##       ##     ## ##
    ######### ######   ##       ########  ######   ########   ######
    ##     ## ##       ##       ##        ##       ##   ##         ##
    ##     ## ##       ##       ##        ##       ##    ##  ##    ##
    ##     ## ######## ######## ##        ######## ##     ##  ######

    def broadcast_message(payload)
      GameDataChannel.broadcast_to current_player.game, message: payload.to_json
    end

    def all_players_in?(game)
      game.player_count == game.players.count{|p| p.subscribed?}
    end

    def disconnect_all_players(game)
      game.players.each do |player|
        ActionCable.server.remote_connections.where(current_player: player).disconnect
      end
    end
end
