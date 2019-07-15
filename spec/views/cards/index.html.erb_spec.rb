require 'rails_helper'

RSpec.describe "cards/index", type: :view do
  before(:each) do
    assign(:cards, [
      Card.create!(
        :word => "Word"
      ),
      Card.create!(
        :word => "Word"
      )
    ])
  end

  xit "renders a list of cards" do
    render
    assert_select "tr>td", :text => "Word".to_s, :count => 2
  end
end
