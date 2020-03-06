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
end
