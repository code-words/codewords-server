require 'rails_helper'

RSpec.describe "GameCards", type: :request do
  describe "GET /game_cards" do
    it "works! (now write some real specs)" do
      get game_cards_path
      expect(response).to have_http_status(200)
    end
  end
end
