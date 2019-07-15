require 'rails_helper'

RSpec.describe "guesses/new", type: :view do
  before(:each) do
    assign(:guess, Guess.new(
      :game => nil,
      :gamecard => nil,
      :team => 1
    ))
  end

  xit "renders new guess form" do
    render

    assert_select "form[action=?][method=?]", guesses_path, "post" do

      assert_select "input[name=?]", "guess[game_id]"

      assert_select "input[name=?]", "guess[gamecard_id]"

      assert_select "input[name=?]", "guess[team]"
    end
  end
end
