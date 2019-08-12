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
    expect(player.role).to eq(nil)
  end

  xit 'allows a player to select their role' do
  end

  xit 'rejects team/role selections once the game has started' do
  end

  xit 'rejects a team selection if the team is full' do
  end

  xit 'rejects a role selection if there are no more slots available for that role' do
  end

  xit 'rejects a team selection if that team already has the sending player\'s role' do
  end

  xit 'rejects a role selection if that role is taken for the current team' do
  end
end
