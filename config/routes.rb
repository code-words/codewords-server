Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope module: 'api/v1', path: 'api/v1' do
    post '/games', to: 'games#create', as: :create_game
    post '/games/:invite_code/players', to: 'games#join', as: :join_game
  end
end
