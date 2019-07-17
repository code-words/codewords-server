require 'rails_helper'

RSpec.describe Player, type: :model do
  describe "Validations" do
    it { should have_secure_token }
  end

  describe "Relationships" do
    it { should belong_to(:game) }
    it { should belong_to(:user) }
  end

  describe "Instance Methods" do
    describe ".name" do
      it 'returns the associated user\'s name' do
        user = User.create(name: "Archer")
        game = Game.create()
        player = game.players.create(user: user)

        expect(player.name).to eq(user.name)
      end
    end
  end
end
