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

  it 'broadcasts a valid hint to all players' do
    intel = @game.players.create(user: User.create(name: "Cheryl"), role: :intel, team: :red)
    stub_connection current_player: intel
    subscription = subscribe

    built_player = Player.find(intel.id)
    built_player.update(role: :intel)
    @game.current_player = built_player
    @game.save
    teammate = Player.where(game: @game, team: built_player.team).where.not(id: built_player.id).first
    teammate.update(role: :spy)

    expect{subscription.send_hint(hintWord: "Bob", numCards: 3)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("hint-provided")

        payload = message[:data]
        expect(payload).to have_key(:isBlueTeam)
        expect(payload).to have_key(:hintWord)
        expect(payload).to have_key(:relatedCards)
      }

    @game.reload
    expect(@game.current_player).to eq(teammate)
    expect(@game.guesses_remaining).to eq(4)

    hint = Hint.last
    expect(hint.word).to eq("Bob")
    expect(hint.num).to eq(3)
  end

  it 'rejects a hint if sending player is not current player' do
    intel = @game.players.create(user: User.create(name: "Cheryl"), role: :intel)
    stub_connection current_player: intel
    subscription = subscribe

    @game.current_player = Player.where.not(id: intel.id).first
    @game.save

    expect{subscription.send_hint(hintWord: "Bob", numCards: 3)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("#{intel.name} attempted to submit a hint out of turn")
        expect(payload[:byPlayerId]).to eq(intel.id)
      }
  end

  it 'rejects a hint if sending player does not have intel role' do
    random_player = @game.players.create(user: User.create(name: "Cheryl"), role: :spy)
    stub_connection current_player: random_player
    subscription = subscribe

    built_player = Player.find(random_player.id)
    built_player.update(role: :spy)
    @game.current_player = built_player
    @game.save
    teammate = @game.players.where(team: random_player.team).where.not(id: random_player.id)
    teammate.update(role: :intel)

    expect{subscription.send_hint(hintWord: "Bob", numCards: 3)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("#{random_player.name} attempted to submit a hint, but doesn't have the Intel role")
        expect(payload[:byPlayerId]).to eq(random_player.id)
      }
  end

  it 'rejects a hint if hint text is invalid' do
    intel = @game.players.create(user: User.create(name: "Cheryl"), role: :intel)
    stub_connection current_player: intel
    subscription = subscribe

    built_player = Player.find(intel.id)
    built_player.update(role: :intel)
    @game.current_player = built_player
    @game.save
    teammate = @game.players.where(team: intel.team).where.not(id: intel.id)
    teammate.update(role: :spy)

    expect{subscription.send_hint(hintWord: "Bob Loblaw", numCards: 3)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("#{intel.name} attempted to submit an invalid hint")
        expect(payload[:byPlayerId]).to eq(intel.id)
      }
  end
end
