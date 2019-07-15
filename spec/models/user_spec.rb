require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "Relationships" do
    it { should have_many(:players) }
    it { should have_many(:games).through(:players) }
  end
end
