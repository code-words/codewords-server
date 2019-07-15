require 'rails_helper'

RSpec.describe Guess, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:team) }
  end

  describe "Relationships" do
    it { should belong_to(:game) }
    it { should belong_to(:game_card) }
  end
end
