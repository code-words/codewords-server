require 'rails_helper'

RSpec.describe Game, type: :model do
  describe "Validations" do
    it { should have_secure_token(:game_key) }
    it { should have_secure_token(:intel_key) }
    it { should have_secure_token(:invite_code) }
  end

  describe "Relationships" do
    it { should have_many(:players) }
    it { should have_many(:users).through(:players) }
    it { should have_many(:game_cards) }
    it { should have_many(:cards).through(:game_cards) }
    it { should have_many(:hints) }
    it { should have_many(:guesses) }
  end

  describe "Instance Methods" do
    let(:game){ Game.create() }
    let(:player1){ User.create(name: "Archer")}
    let(:player2){ User.create(name: "Lana")}
    let(:player3){ User.create(name: "Cyril")}
    let(:player4){ User.create(name: "Cheryl")}

    describe '.username_taken?' do
      it 'returns false if the username is not yet taken' do
        game.users += [player1, player2, player3]
        result = game.username_taken? player4.name

        expect(result).to eq(false)
      end

      it 'returns true if another player on the game has the given username' do
        game.users += [player1, player2, player3]
        result = game.username_taken? player2.name

        expect(result).to eq(true)
      end
    end

    describe '.full?' do
      it 'returns false if the game is not yet full' do
        game.users += [player1, player2, player3]
        result = game.full?

        expect(result).to eq(false)
      end

      it 'returns true if the game is full' do
        game.users += [player1, player2, player3, player4]
        result = game.full?

        expect(result).to eq(true)
      end
    end
  end
end
