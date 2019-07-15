require 'rails_helper'

RSpec.describe "hints/edit", type: :view do
  before(:each) do
    @hint = assign(:hint, Hint.create!(
      :game => nil,
      :word => "MyString",
      :num => 1,
      :team => 1
    ))
  end

  xit "renders the edit hint form" do
    render

    assert_select "form[action=?][method=?]", hint_path(@hint), "post" do

      assert_select "input[name=?]", "hint[game_id]"

      assert_select "input[name=?]", "hint[word]"

      assert_select "input[name=?]", "hint[num]"

      assert_select "input[name=?]", "hint[team]"
    end
  end
end
