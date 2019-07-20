require 'rails_helper'

describe GameDataChannel, type: :channel do
  let(:user){User.create(name: "Archer")}
  let(:game){Game.create}

  before do
    @player = game.players.create(user: user)
    stub_connection current_player: @player
  end

  it 'subscribes to a room' do
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for("game_#{game.game_key}")
  end

  it 'broadcasts joining player info' do
    expect{ subscribe }.to have_broadcasted_to("game_#{game.game_key}")
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("player-joined")
        payload = message[:data]
        expect(payload[:id]).to eq(@player.id)
        expect(payload[:name]).to eq(@player.name)

        players = payload[:playerRoster]
        expect(players).to be_instance_of(Array)
        expect(players[0]).to have_key(:id)
        expect(players[0]).to have_key(:name)
      }
  end

  it 'broadcasts game start info once all players are in' do
    subscribe

    user2 = game.users << User.create(name: "Lana")
    stub_connection current_player: user2.players.first
    subscribe

    user3 = game.users << User.create(name: "Cyril")
    stub_connection current_player: user3.players.first
    subscribe

    user4 = game.users << User.create(name: "Cheryl")
    stub_connection current_player: user4.players.first

    expect{ subscribe }.to have_broadcasted_to("game_#{game.game_key}")
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        unless message[:type] == "player-joined"
          expect(message[:type]).to eq("game-start")

          payload = message[:data]
          expect(payload).to have_key(:cards)

          payload[:cards].each do |card|
            expect(card).to have_key(:id)
            expect(card).to have_key(:word)
          end

          expect(payload).to have_key(:players)

          payload[:players].each do |player|
            expect(player).to have_key(:id)
            expect(player).to have_key(:name)
            expect(player).to have_key(:isBlueTeam)
            expect(player).to have_key(:isIntel)
          end

          expect(payload).to have_key(:firstTeam)
        end
      }
  end
end
