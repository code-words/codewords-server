require 'rails_helper'

describe GameDataChannel, type: :channel do
  let(:user){User.create(name: "Archer")}
  let(:game){Game.create()}

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
end
