require "rails_helper"

describe ApplicationCable::Connection, type: :channel do
  it 'successfully connects' do
    user = User.create(name: "Archer")
    game = Game.create()
    player = game.players.create(user: user)
    connect "/cable", params: { token: player.token }
    expect(connection.current_player).to eq(player)
  end

  it 'rejects connection' do
    expect { connect '/cable'}.to have_rejected_connection
  end
end
