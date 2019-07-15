require 'rails_helper'

RSpec.describe "game_cards/index", type: :view do
  before(:each) do
    assign(:game_cards, [
      GameCard.create!(
        :game => nil,
        :card => nil,
        :type => 2,
        :address => 3,
        :chosen => false
      ),
      GameCard.create!(
        :game => nil,
        :card => nil,
        :type => 2,
        :address => 3,
        :chosen => false
      )
    ])
  end

  xit "renders a list of game_cards" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
