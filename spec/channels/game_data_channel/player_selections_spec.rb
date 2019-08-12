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

  it 'allows a player to select their role' do
    player = game.players.create(user: User.create(name: "Cheryl"))
    stub_connection current_player: player
    subscription = subscribe

    expect{subscription.select_role({"role" => "intel"})}
      .to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("player-update")

        payload = message[:data]
        expect(payload[:id]).to eq(player.id)
        expect(payload[:isBlueTeam]).to eq(nil)
        expect(payload[:isIntel]).to eq(true)
      }

    player.reload
    expect(player.team).to eq(nil)
    expect(player.intel?).to eq(true)
  end

  xit 'rejects team/role selections once the game has started' do
  end

  it 'rejects a team selection if the team is full' do
    archer = game.players.create(user: User.create(name: "Archer"), team: :red)
    lana = game.players.create(user: User.create(name: "Lana"), team: :red)
    player = game.players.create(user: User.create(name: "Cheryl"))
    stub_connection current_player: player
    subscription = subscribe

    expect{subscription.select_team({"team" => "red"})}
      .to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("The red team is full.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }

    player.reload
    expect(player.team).to eq(nil)
    expect(player.role).to eq(nil)
  end

  xit 'rejects a role selection if there are no more slots available for that role' do
  end

  xit 'rejects a team selection if that team already has the sending player\'s role' do
  end

  xit 'rejects a role selection if that role is taken for the current team' do
  end
end
