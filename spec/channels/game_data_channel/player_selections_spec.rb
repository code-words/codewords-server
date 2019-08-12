require 'rails_helper'

describe GameDataChannel, type: :channel do
  let(:game){Game.create}

  it 'allows a player to select their team' do
    player = game.players.create(user: User.create(name: "Cheryl"))
    stub_connection current_player: player
    subscription = subscribe

    expect{subscription.select_team({"team" => "red"})}
      .to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("player-update")

        payload = message[:data]
        expect(payload[:id]).to eq(player.id)
        expect(payload[:isBlueTeam]).to eq(false)
        expect(payload[:isIntel]).to eq(nil)
      }

    player.reload
    expect(player.red?).to eq(true)
    expect(player.intel?).to eq(nil)
  end
end
