require 'rails_helper'

describe GameDataChannel, type: :channel do
  let(:user){User.create(name: "Archer")}
  let(:game){Game.create}

  before(:each) do
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

  it 'does not broadcast game start until all players are in' do
    expect{ subscribe }.to have_broadcasted_to("game_#{game.game_key}").once

    player2 = Player.create(game: game, user: User.create(name: "Lana"))
    stub_connection current_player: player2
    expect{ subscribe }.to have_broadcasted_to("game_#{game.game_key}").once

    player3 = Player.create(game: game, user: User.create(name: "Cyril"))
    stub_connection current_player: player3

    expect{ subscribe }.to have_broadcasted_to("game_#{game.game_key}").once
  end

  it 'broadcasts game start info once all players are in' do
    subscribe

    player2 = Player.create(game: game, user: User.create(name: "Lana"))
    stub_connection current_player: player2
    subscribe

    player3 = Player.create(game: game, user: User.create(name: "Cyril"))
    stub_connection current_player: player3
    subscribe

    player4 = Player.create(game: game, user: User.create(name: "Cheryl"))
    stub_connection current_player: player4

    # track number of times game-setup broadcast
    game_setup_count = 0

    expect{ subscribe }.to have_broadcasted_to("game_#{game.game_key}")
      .twice # once with player-joined, once with game-setup
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        unless message[:type] == "player-joined"
          expect(message[:type]).to eq("game-setup")
          # increment count of game-setup messages
          game_setup_count += 1

          payload = message[:data]
          expect(payload).to have_key(:cards)
          expect(payload[:cards].count).to eq(25)

          payload[:cards].each do |card|
            expect(card).to have_key(:id)
            expect(card).to have_key(:word)
          end

          expect(payload).to have_key(:players)
          expect(payload[:players].count).to eq(4)

          payload[:players].each do |player|
            expect(player).to have_key(:id)
            expect(player).to have_key(:name)
            expect(player).to have_key(:isBlueTeam)
            expect(player).to have_key(:isIntel)
          end

          expect(payload).to have_key(:firstTeam)
        else
          # player-joined message should happen once, so allow that to pass
          expect(message[:type]).to eq("player-joined")
        end
      }
    # game-setup should have incremented once in the two broadcasts above
    expect(game_setup_count).to eq(1)
  end
end
