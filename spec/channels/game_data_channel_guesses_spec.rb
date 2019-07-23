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

  it 'broadcasts a valid guess to all players' do
    intel = @game.players.create(user: User.create(name: "Cheryl"), role: :spy, team: :red)
    stub_connection current_player: intel
    subscription = subscribe

    built_player = Player.find(intel.id)
    built_player.update(role: :spy)
    @game.current_player = built_player
    @game.guesses_remaining = 3
    @game.save
    teammate = Player.where(game: @game, team: built_player.team).where.not(id: built_player.id).first
    teammate.update(role: :intel)

    guess_card = @game.game_cards.where(category: built_player.team).first

    expect{subscription.send_guess(id: guess_card.id)}
      .to have_broadcasted_to(@game)
      .from_channel(GameDataChannel)
      .once
      .with{ |data|
        message = JSON.parse(data[:message], symbolize_names: true)
        expect(message[:type]).to eq("board-update")

        payload = message[:data]
        received_card = payload[:card]
        expect(received_card[:id]).to eq(guess_card.id)
        expect(received_card[:flipped]).to eq(true)
        expect(received_card[:type]).to eq(guess_card.team)

        expect(payload[:remainingAttempts]).to eq(2)
        expect(payload[:currentPlayer]).to eq(built_player.id)
      }

    @game.reload
    expect(@game.current_player).to eq(built_player)
    expect(@game.guesses_remaining).to eq(2)

    guess = Guess.last
    expect(guess.game_card).to eq(guess_card)
    expect(guess.team).to eq(built_player.team)
  end
end
