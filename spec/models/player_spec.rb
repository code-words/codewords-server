require 'rails_helper'

RSpec.describe Player, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:team) }
    it { should validate_presence_of(:role) }
  end

  describe "Relationships" do
    it { should belong_to(:game) }
    it { should belong_to(:user) }
  end
end
