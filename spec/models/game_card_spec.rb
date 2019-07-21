require 'rails_helper'

RSpec.describe GameCard, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:category) }
    it { should validate_numericality_of(:address) }
  end

  describe "Relationships" do
    it { should belong_to(:game) }
    it { should belong_to(:card) }
  end

  describe "Instance Methods" do
    describe ".word" do
      it "should return the word of the associated Card" do
        card = Card.create(word: "Puzzle")
        game = Game.create
        game_card = GameCard.create(game: game, card: card, category: :assassin)

        expect(game_card.word).to eq("Puzzle")
      end
    end
  end
end
