require 'rails_helper'

RSpec.describe "players/edit", type: :view do
  before(:each) do
    @player = assign(:player, Player.create!(
      :user => nil,
      :game => nil,
      :role => 1,
      :team => 1
    ))
  end

  xit "renders the edit player form" do
    render

    assert_select "form[action=?][method=?]", player_path(@player), "post" do

      assert_select "input[name=?]", "player[user_id]"

      assert_select "input[name=?]", "player[game_id]"

      assert_select "input[name=?]", "player[role]"

      assert_select "input[name=?]", "player[team]"
    end
  end
end
