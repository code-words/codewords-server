require 'rails_helper'

RSpec.describe "games/show", type: :view do
  before(:each) do
    @game = assign(:game, Game.create!())
  end

  xit "renders attributes in <p>" do
    render
  end
end
