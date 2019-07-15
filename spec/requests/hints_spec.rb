require 'rails_helper'

RSpec.describe "Hints", type: :request do
  describe "GET /hints" do
    xit "works! (now write some real specs)" do
      get hints_path
      expect(response).to have_http_status(200)
    end
  end
end
