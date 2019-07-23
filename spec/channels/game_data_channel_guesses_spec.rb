require 'rails_helper'

describe GameDataChannel, type: :channel do
  before(:each) do
    @game = Game.create
    ["Archer", "Lana", "Cyril"].each do |name|
      player = @game.players.create(user: User.create(name: name))
      stub_connection current_player: player
      subscribe
    end
  end

  it 'broadcasts a valid guess to all players' do
    intel = @game.players.create(user: User.create(name: "Cheryl"), role: :spy, team: :red)
    stub_connection current_player: intel
    subscription = subscribe

    built_player = Player.find(intel.id)
    built_player.update(role: :spy)
    @game.current_player = built_player
    @game.guesses_remaining = 3
    @game.save
    teammate = Player.where(game: @game, team: built_player.team).where.not(id: built_player.id).first
    teammate.update(role: :intel)

    guess_card = @game.game_cards.where(category: built_player.team).first

    expect{subscription.send_guess(id: guess_card.id)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("board-update")

        payload = message[:data]
        received_card = payload[:card]
        expect(received_card[:id]).to eq(guess_card.id)
        expect(received_card[:flipped]).to eq(true)
        expect(received_card[:type]).to eq(guess_card.category)

        expect(payload[:remainingAttempts]).to eq(2)
        expect(payload[:currentPlayer]).to eq(built_player.id)
      }

    @game.reload
    expect(@game.current_player).to eq(built_player)
    expect(@game.guesses_remaining).to eq(2)

    guess = Guess.last
    expect(guess.game_card).to eq(guess_card)
    expect(guess.team).to eq(built_player.team)
  end

  it 'rejects a guess if sending player is not current player' do
    intel = @game.players.create(user: User.create(name: "Cheryl"), role: :intel)
    stub_connection current_player: intel
    subscription = subscribe

    @game.current_player = Player.where.not(id: intel.id).first
    @game.guesses_remaining = 1
    @game.save

    guess_card = @game.game_cards.where(category: @game.current_player.team).first

    expect{subscription.send_guess(id: guess_card.id)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("#{intel.name} attempted to submit a guess out of turn")
        expect(payload[:byPlayerId]).to eq(intel.id)
      }
  end

  it 'rejects a guess if sending player does not have spy role' do
    random_player = @game.players.create(user: User.create(name: "Cheryl"), role: :intel)
    stub_connection current_player: random_player
    subscription = subscribe

    built_player = Player.find(random_player.id)
    built_player.update(role: :intel)
    @game.current_player = built_player
    @game.save
    teammate = @game.players.where(team: random_player.team).where.not(id: random_player.id)
    teammate.update(role: :spy)

    guess_card = @game.game_cards.where(category: built_player.team).first

    expect{subscription.send_guess(id: guess_card.id)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("#{random_player.name} attempted to submit a guess, but doesn't have the Spy role")
        expect(payload[:byPlayerId]).to eq(random_player.id)
      }
  end
end
