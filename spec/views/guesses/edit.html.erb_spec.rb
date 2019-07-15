require 'rails_helper'

RSpec.describe "guesses/edit", type: :view do
  before(:each) do
    @guess = assign(:guess, Guess.create!(
      :game => nil,
      :gamecard => nil,
      :team => 1
    ))
  end

  xit "renders the edit guess form" do
    render

    assert_select "form[action=?][method=?]", guess_path(@guess), "post" do

      assert_select "input[name=?]", "guess[game_id]"

      assert_select "input[name=?]", "guess[gamecard_id]"

      assert_select "input[name=?]", "guess[team]"
    end
  end
end
