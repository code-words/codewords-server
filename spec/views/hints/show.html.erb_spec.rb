require 'rails_helper'

RSpec.describe "hints/show", type: :view do
  before(:each) do
    @hint = assign(:hint, Hint.create!(
      :game => nil,
      :word => "Word",
      :num => 2,
      :team => 3
    ))
  end

  xit "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Word/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
