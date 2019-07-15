require 'rails_helper'

RSpec.describe "Guesses", type: :request do
  describe "GET /guesses" do
    xit "works! (now write some real specs)" do
      get guesses_path
      expect(response).to have_http_status(200)
    end
  end
end
