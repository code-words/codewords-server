require "rails_helper"

RSpec.describe GameCardsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/game_cards").to route_to("game_cards#index")
    end

    it "routes to #new" do
      expect(:get => "/game_cards/new").to route_to("game_cards#new")
    end

    it "routes to #show" do
      expect(:get => "/game_cards/1").to route_to("game_cards#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/game_cards/1/edit").to route_to("game_cards#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/game_cards").to route_to("game_cards#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/game_cards/1").to route_to("game_cards#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/game_cards/1").to route_to("game_cards#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/game_cards/1").to route_to("game_cards#destroy", :id => "1")
    end
  end
end
