require 'rails_helper'

RSpec.describe "cards/show", type: :view do
  before(:each) do
    @card = assign(:card, Card.create!(
      :word => "Word"
    ))
  end

  xit "renders attributes in <p>" do
    render
    expect(rendered).to match(/Word/)
  end
end
