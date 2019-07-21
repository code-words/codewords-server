class WelcomeController < ApplicationController
  def index
    @developers = [
      {name: "Rachael Drennan", github: "rdren0"},
      {name: "Justin Pyktel", github: "SiimonStark"},
      {name: "Lynne Rang", github: "lynnerang"},
      {name: "Jon Peterson", github: "joequincy"}
    ]
  end
end
