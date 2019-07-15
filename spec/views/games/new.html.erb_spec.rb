require 'rails_helper'

RSpec.describe "games/new", type: :view do
  before(:each) do
    assign(:game, Game.new())
  end

  xit "renders new game form" do
    render

    assert_select "form[action=?][method=?]", games_path, "post" do
    end
  end
end
