Rails.application.routes.draw do
  root 'home#index'

  scope module: 'api/v1', path: 'api/v1' do
    post '/games', to: 'games#create', as: :create_game
    post '/games/:invite_code/players', to: 'games#join', as: :join_game
  end

  mount ActionCable.server => '/cable/:token'
end
