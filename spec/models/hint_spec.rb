require 'rails_helper'

RSpec.describe Hint, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:word) }
    it { should validate_presence_of(:team) }
    it { should validate_numericality_of(:num) }
  end

  describe "Relationships" do
    it { should belong_to(:game) }
  end
end
