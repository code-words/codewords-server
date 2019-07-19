require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "POST /api/v1/games" do
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

  describe "POST /api/v1/games/:invite_code/players" do
    it "adds the new player" do
      post create_game_path, params: {name: "Archer"}, headers: {'Accept' => 'application/json'}
      invite_code = JSON.parse(response.body, symbolize_names: true)[:invite_code]

      post join_game_path(invite_code), params: {name: "Lana"}, headers: {'Accept' => 'application/json'}
      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:name]).to eq("Lana")
      expect(data).to have_key(:game_channel)
      expect(data).to have_key(:token)
    end

    it "requires a username" do
      post create_game_path, params: {name: "Archer"}, headers: {'Accept' => 'application/json'}
      invite_code = JSON.parse(response.body, symbolize_names: true)[:invite_code]

      post join_game_path(invite_code)
      expect(response).to have_http_status(:unauthorized)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq("You must provide a username")
    end

    it "blocks duplicate usernames" do
      post create_game_path, params: {name: "Archer"}, headers: {'Accept' => 'application/json'}
      invite_code = JSON.parse(response.body, symbolize_names: true)[:invite_code]

      post join_game_path(invite_code), params: {name: "Archer"}, headers: {'Accept' => 'application/json'}
      expect(response).to have_http_status(:unauthorized)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq("That username is already taken")
    end

    it "requires a valid invite code" do
      post create_game_path, params: {name: "Archer"}, headers: {'Accept' => 'application/json'}
      invite_code = "some-nonsense"

      post join_game_path(invite_code), params: {name: "Lana"}, headers: {'Accept' => 'application/json'}
      expect(response).to have_http_status(:unauthorized)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq("That invite code is invalid")
    end

    it "prevents overfilling a game" do
      post create_game_path, params: {name: "Archer"}, headers: {'Accept' => 'application/json'}
      invite_code = JSON.parse(response.body, symbolize_names: true)[:invite_code]
      post join_game_path(invite_code), params: {name: "Lana"}, headers: {'Accept' => 'application/json'}
      post join_game_path(invite_code), params: {name: "Cyril"}, headers: {'Accept' => 'application/json'}
      post join_game_path(invite_code), params: {name: "Cheryl"}, headers: {'Accept' => 'application/json'}

      post join_game_path(invite_code), params: {name: "Brett"}, headers: {'Accept' => 'application/json'}
      expect(response).to have_http_status(:unauthorized)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq("That game is already full")
    end
  end
end
