require 'rails_helper'

RSpec.describe "game_cards/new", type: :view do
  before(:each) do
    assign(:game_card, GameCard.new(
      :game => nil,
      :card => nil,
      :type => 1,
      :address => 1,
      :chosen => false
    ))
  end

  xit "renders new game_card form" do
    render

    assert_select "form[action=?][method=?]", game_cards_path, "post" do

      assert_select "input[name=?]", "game_card[game_id]"

      assert_select "input[name=?]", "game_card[card_id]"

      assert_select "input[name=?]", "game_card[type]"

      assert_select "input[name=?]", "game_card[address]"

      assert_select "input[name=?]", "game_card[chosen]"
    end
  end
end
