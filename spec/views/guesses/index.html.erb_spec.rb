require 'rails_helper'

RSpec.describe "guesses/index", type: :view do
  before(:each) do
    assign(:guesses, [
      Guess.create!(
        :game => nil,
        :gamecard => nil,
        :team => 2
      ),
      Guess.create!(
        :game => nil,
        :gamecard => nil,
        :team => 2
      )
    ])
  end

  xit "renders a list of guesses" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
