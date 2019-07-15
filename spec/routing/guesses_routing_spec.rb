require "rails_helper"

RSpec.describe GuessesController, type: :routing do
  describe "routing" do
    xit "routes to #index" do
      expect(:get => "/guesses").to route_to("guesses#index")
    end

    xit "routes to #new" do
      expect(:get => "/guesses/new").to route_to("guesses#new")
    end

    xit "routes to #show" do
      expect(:get => "/guesses/1").to route_to("guesses#show", :id => "1")
    end

    xit "routes to #edit" do
      expect(:get => "/guesses/1/edit").to route_to("guesses#edit", :id => "1")
    end


    xit "routes to #create" do
      expect(:post => "/guesses").to route_to("guesses#create")
    end

    xit "routes to #update via PUT" do
      expect(:put => "/guesses/1").to route_to("guesses#update", :id => "1")
    end

    xit "routes to #update via PATCH" do
      expect(:patch => "/guesses/1").to route_to("guesses#update", :id => "1")
    end

    xit "routes to #destroy" do
      expect(:delete => "/guesses/1").to route_to("guesses#destroy", :id => "1")
    end
  end
end
