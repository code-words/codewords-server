require 'rails_helper'

RSpec.describe Game, type: :model do
  describe "Relationships" do
    it { should have_many(:players) }
    it { should have_many(:users).through(:players) }
    it { should have_many(:game_cards) }
    it { should have_many(:cards).through(:game_cards) }
    it { should have_many(:hints) }
    it { should have_many(:guesses) }
  end
end
