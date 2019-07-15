require 'rails_helper'

RSpec.describe "hints/new", type: :view do
  before(:each) do
    assign(:hint, Hint.new(
      :game => nil,
      :word => "MyString",
      :num => 1,
      :team => 1
    ))
  end

  xit "renders new hint form" do
    render

    assert_select "form[action=?][method=?]", hints_path, "post" do

      assert_select "input[name=?]", "hint[game_id]"

      assert_select "input[name=?]", "hint[word]"

      assert_select "input[name=?]", "hint[num]"

      assert_select "input[name=?]", "hint[team]"
    end
  end
end
