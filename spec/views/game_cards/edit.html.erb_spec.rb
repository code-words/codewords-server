require 'rails_helper'

RSpec.describe "game_cards/edit", type: :view do
  before(:each) do
    @game_card = assign(:game_card, GameCard.create!(
      :game => nil,
      :card => nil,
      :type => 1,
      :address => 1,
      :chosen => false
    ))
  end

  xit "renders the edit game_card form" do
    render

    assert_select "form[action=?][method=?]", game_card_path(@game_card), "post" do

      assert_select "input[name=?]", "game_card[game_id]"

      assert_select "input[name=?]", "game_card[card_id]"

      assert_select "input[name=?]", "game_card[type]"

      assert_select "input[name=?]", "game_card[address]"

      assert_select "input[name=?]", "game_card[chosen]"
    end
  end
end
