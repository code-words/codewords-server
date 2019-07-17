require 'rails_helper'

describe IntelDataChannel, type: :channel do
  let(:user){User.create(name: "Archer")}
  let(:game){Game.create()}

  before do
    @player = game.players.create(user: user)
    stub_connection current_player: @player
  end

  it 'rejects when the player does not have intel permission' do
    subscribe

    expect(subscription).to be_rejected
  end

  it 'subscribes when the player has intel permission' do
    @player.role = :intel
    @player.save
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for("intel_#{game.intel_key}")
  end
end
