require 'rails_helper'

describe GameDataChannel, type: :channel do
  let(:user){User.create(name: "Archer")}
  let(:game){Game.create()}

  before do
    player = game.players.create(user: user)
    stub_connection current_player: player
  end

  it 'subscribes to a room' do
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for("game_#{game.game_key}")
  end
end
