require 'rails_helper'

RSpec.describe "game_cards/show", type: :view do
  before(:each) do
    @game_card = assign(:game_card, GameCard.create!(
      :game => nil,
      :card => nil,
      :type => 2,
      :address => 3,
      :chosen => false
    ))
  end

  xit "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/false/)
  end
end
