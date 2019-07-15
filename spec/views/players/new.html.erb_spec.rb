require 'rails_helper'

RSpec.describe "players/new", type: :view do
  before(:each) do
    assign(:player, Player.new(
      :user => nil,
      :game => nil,
      :role => 1,
      :team => 1
    ))
  end

  xit "renders new player form" do
    render

    assert_select "form[action=?][method=?]", players_path, "post" do

      assert_select "input[name=?]", "player[user_id]"

      assert_select "input[name=?]", "player[game_id]"

      assert_select "input[name=?]", "player[role]"

      assert_select "input[name=?]", "player[team]"
    end
  end
end
