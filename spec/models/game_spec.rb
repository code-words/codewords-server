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
end
