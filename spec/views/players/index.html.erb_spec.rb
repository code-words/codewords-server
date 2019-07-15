require 'rails_helper'

RSpec.describe "players/index", type: :view do
  before(:each) do
    assign(:players, [
      Player.create!(
        :user => nil,
        :game => nil,
        :role => 2,
        :team => 3
      ),
      Player.create!(
        :user => nil,
        :game => nil,
        :role => 2,
        :team => 3
      )
    ])
  end

  xit "renders a list of players" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
