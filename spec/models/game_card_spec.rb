require 'rails_helper'

RSpec.describe GameCard, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:chosen) }
    it { should validate_numericality_of(:address) }
  end

  describe "Relationships" do
    it { should belong_to(:game) }
    it { should belong_to(:card) }
  end
end
