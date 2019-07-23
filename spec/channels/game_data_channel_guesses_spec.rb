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
    spy = @game.players.create(user: User.create(name: "Cheryl"), role: :spy, team: :red)
    stub_connection current_player: spy
    subscription = subscribe

    built_player = Player.find(spy.id)
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
    spy = @game.players.create(user: User.create(name: "Cheryl"), role: :intel)
    stub_connection current_player: spy
    subscription = subscribe

    @game.current_player = Player.where.not(id: spy.id).first
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
        expect(payload[:error]).to eq("#{spy.name} attempted to submit a guess out of turn")
        expect(payload[:byPlayerId]).to eq(spy.id)
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
        expect(payload[:error]).to eq("#{built_player.name} attempted to submit a guess, but doesn't have the Spy role")
        expect(payload[:byPlayerId]).to eq(built_player.id)
      }
  end

  it 'rejects a guess if guessed card id does not match a card for the game' do
    spy = @game.players.create(user: User.create(name: "Cheryl"), role: :spy, team: :red)
    stub_connection current_player: spy
    subscription = subscribe

    built_player = Player.find(spy.id)
    built_player.update(role: :spy)
    @game.current_player = built_player
    @game.guesses_remaining = 3
    @game.save
    teammate = Player.where(game: @game, team: built_player.team).where.not(id: built_player.id).first
    teammate.update(role: :intel)

    card_ids = @game.game_cards.pluck(:id)
    guess_id = 1
    until !card_ids.include? guess_id
      guess_id = Random.rand(499) + 1 # ensure not 0
    end

    expect{subscription.send_guess(id: guess_id)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("#{built_player.name} attempted to submit a guess for a card not in this game")
        expect(payload[:byPlayerId]).to eq(built_player.id)
      }
  end

  it 'advances the game if the guess was for a bystander' do
    spy = @game.players.create(user: User.create(name: "Cheryl"), role: :spy, team: :red)
    stub_connection current_player: spy
    subscription = subscribe

    built_player = Player.find(spy.id)
    built_player.update(role: :spy)
    @game.current_player = built_player
    @game.guesses_remaining = 3
    @game.save
    teammate = Player.where(game: @game, team: built_player.team).where.not(id: built_player.id).first
    teammate.update(role: :intel)

    guess_card = @game.game_cards.where(category: :bystander).first
    opposing_team = built_player.blue? ? :red : :blue
    next_player = @game.players.where(team: opposing_team, role: :intel).first

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

        expect(payload[:remainingAttempts]).to eq(0)
        expect(payload[:currentPlayer]).to eq(next_player.id)
      }
  end

  it 'advances the game if the guess was for opposing team\'s card' do
    spy = @game.players.create(user: User.create(name: "Cheryl"), role: :spy, team: :red)
    stub_connection current_player: spy
    subscription = subscribe

    built_player = Player.find(spy.id)
    built_player.update(role: :spy)
    @game.current_player = built_player
    @game.guesses_remaining = 3
    @game.save
    teammate = Player.where(game: @game, team: built_player.team).where.not(id: built_player.id).first
    teammate.update(role: :intel)

    opposing_team = built_player.blue? ? :red : :blue
    guess_card = @game.game_cards.where(category: opposing_team).first
    next_player = @game.players.where(team: opposing_team, role: :intel).first

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

        expect(payload[:remainingAttempts]).to eq(0)
        expect(payload[:currentPlayer]).to eq(next_player.id)
      }
  end
end
