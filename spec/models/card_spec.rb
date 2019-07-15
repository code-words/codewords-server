require 'rails_helper'

RSpec.describe Card, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:word) }
  end

  describe "Relationships" do
    it { should have_many(:game_cards) }
    it { should have_many(:games).through(:game_cards) }
  end
end
