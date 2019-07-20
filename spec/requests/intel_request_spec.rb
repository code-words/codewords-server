require 'rails_helper'

RSpec.describe "Intel", type: :request do
  describe "GET /api/v1/intel" do
    describe "success" do
      it "returns the card metadata for the game" do
        require './db/seeds/cards'
        game = Game.create
        game.users << User.create(name: "Archer")
        game.users << User.create(name: "Lana")
        game.users << User.create(name: "Cyril")
        game.users << User.create(name: "Cheryl")
        players = game.players

        oldLogger = ActiveRecord::Base.logger
        game.establish!

        players[0].role = :intel
        players[0].save

        get get_intel_path, params: {token: players[0].token}, headers: {'Accept' => 'application/json'}

        expect(response).to have_http_status(:ok)

        data = JSON.parse(response.body, symbolize_names: true)
        expect(data[:cards]).to be_instance_of(Array)

        example_card = data[:cards].sample
        expect(example_card).to have_key(:id)
        expect(example_card).to have_key(:type)
      end
    end

    describe "errors" do
      it "requires a token" do
        get get_intel_path, headers: {'Accept' => 'application/json'}

        expect(response).to have_http_status(:unauthorized)

        data = JSON.parse(response.body, symbolize_names: true)
        expect(data[:error]).to eq("You must provide your access token")
      end

      it "requires token to be valid" do
        user = User.create(name: "Archer")
        game = Game.create
        player = game.players.create(user: user, role: :intel)
        get get_intel_path, params: {token: "nonsense"}, headers: {'Accept' => 'application/json'}

        expect(response).to have_http_status(:unauthorized)

        data = JSON.parse(response.body, symbolize_names: true)
        expect(data[:error]).to eq("Unable to find a user with that token")
      end
    end

    it "requires player to have intel access" do
      user = User.create(name: "Archer")
      game = Game.create
      player = game.players.create(user: user)
      get get_intel_path, params: {token: player.token}, headers: {'Accept' => 'application/json'}

      expect(response).to have_http_status(:unauthorized)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq("You are not authorized for this game's secret intel")
    end
  end
end
