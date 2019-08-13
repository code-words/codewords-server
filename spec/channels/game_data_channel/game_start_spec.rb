require 'rails_helper'

describe GameDataChannel, type: :channel do
  let(:user){User.create(name: "Archer")}
  let(:game){Game.create}

  before(:each) do
    @player = game.players.create(user: user)
    stub_connection current_player: @player
  end

  it 'does not start game immediately when last player joins' do
    subscribe

    player2 = Player.create(game: game, user: User.create(name: "Lana"))
    stub_connection current_player: player2
    subscribe

    player3 = Player.create(game: game, user: User.create(name: "Cyril"))
    stub_connection current_player: player3
    subscribe

    player4 = Player.create(game: game, user: User.create(name: "Cheryl"))
    stub_connection current_player: player4

    expect{ subscribe }.to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once # with player-joined, but not with game-setup
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("player-joined")
      }
  end
end
