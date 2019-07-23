require 'rails_helper'

describe GameDataChannel, type: :channel do
  before(:each) do
    @game = Game.create
    ["Archer", "Lana", "Cyril"].each do |name|
      player = @game.players.create(user: User.create(name: name))
      stub_connection current_player: player
      subscribe
    end
  end

  it 'broadcasts a valid hint to all players' do
    intel = @game.players.create(user: User.create(name: "Cheryl"), role: :intel)
    stub_connection current_player: intel
    subscription = subscribe

    built_player = Player.find(intel.id)
    built_player.update(role: :intel)
    @game.current_player = built_player
    @game.save
    teammate = @game.players.where(team: intel.team).where.not(id: intel.id)
    teammate.update(role: :spy)

    expect{subscription.send_hint(hintWord: "Bob", numCards: 3)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("hint-provided")

        payload = message[:data]
        expect(payload).to have_key(:isBlueTeam)
        expect(payload).to have_key(:hintWord)
        expect(payload).to have_key(:relatedCards)
      }
  end
end
