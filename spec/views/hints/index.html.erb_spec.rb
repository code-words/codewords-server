require 'rails_helper'

RSpec.describe "hints/index", type: :view do
  before(:each) do
    assign(:hints, [
      Hint.create!(
        :game => nil,
        :word => "Word",
        :num => 2,
        :team => 3
      ),
      Hint.create!(
        :game => nil,
        :word => "Word",
        :num => 2,
        :team => 3
      )
    ])
  end

  xit "renders a list of hints" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Word".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
