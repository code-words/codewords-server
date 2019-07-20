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
    let(:game){ Game.create }
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

    describe '.establish!' do
      it 'creates a game board with cards' do
        game.users += [player1, player2, player3, player4]
        game.establish!
        cards = game.game_cards.to_a

        cards.each do |card|
          expect(card).to be_instance_of(GameCard)
          expect(card.card).to be_instance_of(Card)
        end

        expect(cards.count).to eq(25)

        red = cards.select{|card| card.red?}
        blue = cards.select{|card| card.blue?}
        expect(red.count).to eq(9) | eq(8)
        expect(blue.count).to eq(9) | eq(8)
        expect(red.count).to_not eq(blue.count)

        bystanders = cards.select{|card| card.bystander?}
        expect(bystanders.count).to eq(7)

        assassin = cards.select{|card| card.assassin?}
        expect(assassin.count).to eq(1)
      end

      it 'assigns players equally to red and blue teams' do
        game.users += [player1, player2, player3, player4]
        game.establish!
        players = game.players.to_a

        players.each do |player|
          expect(player).to be_instance_of(Player)
          expect(player.user).to be_instance_of(User)
        end

        red_players = players.select{|player| player.red?}
        blue_players = players.select{|player| player.blue?}

        if players.count.odd?
          expect(abs(red_players.count - blue_players.count)).to eq(1)
        else
          expect(red_players.count).to eq(blue_players.count)
        end
      end

      it 'assigns one player on each team to be "intel"' do
        game.users += [player1, player2, player3, player4]
        game.establish!
        players = game.players.to_a

        expect(players.one?{|player| player.red? && player.intel?}).to eq(true)
        expect(players.one?{|player| player.blue? && player.intel?}).to eq(true)
      end
    end
  end
end
