Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Rails.env.development? || Rails.env.test?
    allow do
      origins '*'

      resource '*',
      headers: :any,
      methods: :any
    end
  elsif Rails.env.production? && ENV['HEROKU_STAGING']
    allow do
      origins 'localhost', 'localhost:*', 'https://codewords-game-staging.herokuapp.com'

      resource '/api/*',
      headers: :any,
      methods: [:get, :post, :options, :head]
    end

    allow do
      origins '*'

      resource '/',
      headers: :any,
      methods: [:get, :options, :head]
    end
  elsif Rails.env.production?
    allow do
      origins 'http://playcodewords.com', 'http://www.playcodewords.com'

      resource '/api/*',
      headers: :any,
      methods: [:get, :post, :options, :head]
    end
  end
end
