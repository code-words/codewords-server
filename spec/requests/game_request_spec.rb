require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "POST /games" do
    it "creates a game" do
      post create_game_path, params: {name: "Archer"}, headers: {'Accept' => 'application/json'}
      expect(response).to have_http_status(:created)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:name]).to eq("Archer")
      expect(data).to have_key(:game_channel)
      expect(data).to have_key(:invite_code)
      expect(data).to have_key(:token)
    end

    it "requires a username" do
      post create_game_path
      expect(response).to have_http_status(:unauthorized)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq("You must provide a username")
    end
  end
end
