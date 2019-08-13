require 'rails_helper'

describe GameDataChannel, type: :channel do
  let(:user){User.create(name: "Archer")}
  let(:game){Game.create}

  before(:each) do
    @player = game.players.create(user: user)
    stub_connection current_player: @player
  end

  it 'subscribes to a room' do
    expect(@player.subscribed?).to eq(false)

    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(game)

    @player.reload
    expect(@player.subscribed?).to eq(true)
  end

  it 'unsubscribes from a room' do
    subscribe
    unsubscribe

    expect(subscription).to_not have_stream_for(game)

    @player.reload
    expect(@player.subscribed?).to eq(false)
  end

  it 'rejects players rejoining after game over' do
    game.update_attribute(:over, true)

    subscribe

    expect(subscription).to be_rejected
  end

  it 'broadcasts joining player info' do
    expect{ subscribe }.to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("player-joined")
        payload = message[:data]
        expect(payload[:id]).to eq(@player.id)
        expect(payload[:name]).to eq(@player.name)
        expect(payload[:isBlueTeam]).to eq(nil)
        expect(payload[:isIntel]).to eq(nil)

        players = payload[:playerRoster]
        player_ids = []
        expect(players).to be_instance_of(Array)
        players.each do |player|
          expect(player).to have_key(:id)
          expect(player).to have_key(:name)
          expect(player).to have_key(:isBlueTeam)
          expect(player).to have_key(:isIntel)
          player_ids << player[:id]
        end

        player_resources = Player.find(player_ids).to_a
        expect(player_resources).to eq(player_resources.sort_by &:updated_at)
      }
  end

  it 'does not broadcast game start until all players are in' do
    expect{ subscribe }.to have_broadcasted_to(game)
      .from_channel(GameDataChannel).once

    player2 = Player.create(game: game, user: User.create(name: "Lana"))
    stub_connection current_player: player2
    expect{ subscribe }.to have_broadcasted_to(game)
      .from_channel(GameDataChannel).once

    player3 = Player.create(game: game, user: User.create(name: "Cyril"))
    stub_connection current_player: player3

    expect{ subscribe }.to have_broadcasted_to(game)
      .from_channel(GameDataChannel).once
  end

  xit 'broadcasts game start info once all players are in' do
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

    expect{ subscribe }.to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
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

          first_card = GameCard.find(payload[:cards].first[:id])
          expect(first_card.address).to eq(0)

          last_card = GameCard.find(payload[:cards].last[:id])
          expect(last_card.address).to eq(24)

          expect(payload).to have_key(:players)
          expect(payload[:players].count).to eq(4)

          player_ids = []
          payload[:players].each do |player|
            expect(player).to have_key(:id)
            expect(player).to have_key(:name)
            expect(player).to have_key(:isBlueTeam)
            expect(player).to have_key(:isIntel)
            player_ids << player[:id]
          end

          player_resources = Player.find(player_ids).to_a
          expect(player_resources).to eq(player_resources.sort_by &:updated_at)

          expect(payload).to have_key(:firstPlayerId)
        else
          # player-joined message should happen once, so allow that to pass
          expect(message[:type]).to eq("player-joined")
        end
      }
    # game-setup should have incremented once in the two broadcasts above
    expect(game_setup_count).to eq(1)
  end
end
