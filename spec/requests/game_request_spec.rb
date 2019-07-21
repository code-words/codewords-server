require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "POST /api/v1/games" do
    it "creates a game" do
      post create_game_path, params: {name: "Archer"}, headers: {'Accept' => 'application/json'}
      expect(response).to have_http_status(:created)

      player = Player.last
      expect(player.name).to eq("Archer")

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:id]).to eq(player.id)
      expect(data[:name]).to eq(player.name)
      expect(data[:invite_code]).to eq(player.game.invite_code)
      expect(data[:token]).to eq(player.token)
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

      player = Player.last
      expect(player.name).to eq("Lana")

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:id]).to eq(player.id)
      expect(data[:name]).to eq(player.name)
      expect(data[:token]).to eq(player.token)
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
