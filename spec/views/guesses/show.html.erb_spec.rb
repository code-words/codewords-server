require 'rails_helper'

RSpec.describe "guesses/show", type: :view do
  before(:each) do
    @guess = assign(:guess, Guess.create!(
      :game => nil,
      :gamecard => nil,
      :team => 2
    ))
  end

  xit "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
  end
end
