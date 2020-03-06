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

  it 'broadcasts game start info once all players are in and any player sends start_game action' do
    subscribe

    player2 = Player.create(game: game, user: User.create(name: "Lana"))
    stub_connection current_player: player2
    subscribe

    player3 = Player.create(game: game, user: User.create(name: "Cyril"))
    stub_connection current_player: player3
    subscribe

    player4 = Player.create(game: game, user: User.create(name: "Cheryl"))
    stub_connection current_player: player4
    subscription = subscribe

    expect{ subscription.start_game }.to have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("game-setup")

        payload = message[:data]
        expect(payload).to have_key(:cards)
        expect(payload[:cards].count).to eq(25)

        payload[:cards].each do |card|
          expect(card).to have_key(:id)
          expect(card).to have_key(:word)
        end

        first_card = GameCard.find(payload[:cards].first[:id])
        expect(first_card.address).to eq(0)

        last_card = GameCard.find(payload[:cards].last[:id])
        expect(last_card.address).to eq(24)

        expect(payload).to have_key(:players)
        expect(payload[:players].count).to eq(4)

        player_ids = []
        payload[:players].each do |player|
          expect(player).to have_key(:id)
          expect(player).to have_key(:name)
          expect(player).to have_key(:isBlueTeam)
          expect(player).to have_key(:isIntel)
          player_ids << player[:id]
        end

        player_resources = Player.find(player_ids).to_a
        expect(player_resources).to eq(player_resources.sort_by &:updated_at)

        expect(payload).to have_key(:firstPlayerId)
      }
  end

  it 'respects player team/role selections when present' do
    subscribe

    player2 = Player.create(game: game, user: User.create(name: "Lana"), team: :red, role: :intel)
    stub_connection current_player: player2
    subscribe

    player3 = Player.create(game: game, user: User.create(name: "Cyril"), team: :red, role: :spy)
    stub_connection current_player: player3
    subscribe

    player4 = Player.create(game: game, user: User.create(name: "Cheryl"), team: :blue, role: :intel)
    stub_connection current_player: player4
    subscription = subscribe

    expect{ subscription.start_game }.to make_database_queries(count: 1, matching: "UPDATE \"players\"")
      .and have_broadcasted_to(game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("game-setup")
        payload = message[:data]

        archer = payload[:players].find do |player|
          player[:name] == "Archer"
        end

        expect(archer[:isBlueTeam]).to eq(true)
        expect(archer[:isIntel]).to eq(false)
      }
  end
end
