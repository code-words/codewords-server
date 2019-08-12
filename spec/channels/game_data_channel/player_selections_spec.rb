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

  it 'rejects team/role selections once the game has started' do
    archer = game.players.create(user: User.create(name: "Archer"), subscribed: true)
    lana = game.players.create(user: User.create(name: "Lana"), subscribed: true)
    cyril = game.players.create(user: User.create(name: "Cyril"), subscribed: true)
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
        expect(payload[:error]).to eq("Unable to change team. The game has already begun.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }

    expect{subscription.select_role({"role" => "intel"})}
      .to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("Unable to change role. The game has already begun.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }
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

  it 'rejects a role selection if intel and there are no more slots available for that role' do
    archer = game.players.create(user: User.create(name: "Archer"), role: :intel)
    lana = game.players.create(user: User.create(name: "Lana"), role: :intel)
    player = game.players.create(user: User.create(name: "Cheryl"))
    stub_connection current_player: player
    subscription = subscribe

    expect{subscription.select_role({"role" => "intel"})}
      .to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("There are already two Intel players.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }

    player.reload
    expect(player.team).to eq(nil)
    expect(player.role).to eq(nil)
  end

  it 'rejects a role selection if spy and there are no more slots available for that role' do
    archer = game.players.create(user: User.create(name: "Archer"), role: :spy)
    lana = game.players.create(user: User.create(name: "Lana"), role: :spy)
    player = game.players.create(user: User.create(name: "Cheryl"))
    stub_connection current_player: player
    subscription = subscribe

    expect{subscription.select_role({"role" => "spy"})}
      .to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("There is no more room for Spy players.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }

    player.reload
    expect(player.team).to eq(nil)
    expect(player.role).to eq(nil)
  end

  it 'rejects a team selection if player is intel and intel role is taken already' do
    archer = game.players.create(user: User.create(name: "Archer"), team: :red, role: :intel)
    player = game.players.create(user: User.create(name: "Cheryl"), role: :intel)
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
        expect(payload[:error]).to eq("The red team already has a player with the Intel role.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }

    player.reload
    expect(player.team).to eq(nil)
  end

  it 'rejects a team selection if player is spy and spy role is taken already' do
    archer = game.players.create(user: User.create(name: "Archer"), team: :red, role: :spy)
    player = game.players.create(user: User.create(name: "Cheryl"), role: :spy)
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
        expect(payload[:error]).to eq("The red team doesn't have room for more Spy players.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }

    player.reload
    expect(player.team).to eq(nil)
  end

  it 'rejects a role selection if selection is intel and team already has intel' do
    archer = game.players.create(user: User.create(name: "Archer"), team: :red, role: :intel)
    player = game.players.create(user: User.create(name: "Cheryl"), team: :red)
    stub_connection current_player: player
    subscription = subscribe

    expect{subscription.select_role({"role" => "intel"})}
      .to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("The red team already has a player with the Intel role.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }

    player.reload
    expect(player.role).to eq(nil)
  end

  it 'rejects a role selection if selection is spy and team is full of spies' do
    archer = game.players.create(user: User.create(name: "Archer"), team: :red, role: :spy)
    player = game.players.create(user: User.create(name: "Cheryl"), team: :red)
    stub_connection current_player: player
    subscription = subscribe

    expect{subscription.select_role({"role" => "spy"})}
      .to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("illegal-action")

        payload = message[:data]
        expect(payload[:error]).to eq("The red team doesn't have room for more Spy players.")
        expect(payload[:category]).to eq("personal")
        expect(payload[:byPlayerId]).to eq(player.id)
      }

    player.reload
    expect(player.role).to eq(nil)
  end
end
