require 'sinatra'

class Blackjack::Api < Sinatra::Base
  get '/status.json' do
    content_type :json
    { status: :ok, message: nil }.to_json
  end

  post '/game' do
    # Create a deck
    # If game already created, override
  end

  delete '/game' do
    # Deletes a deck
  end

  post '/round' do
    # Use created deck,
    # create player and dealer hands
    # Refuse if round is in progress
    # response with hands and game
  end

  get '/hit/:id.json' do
  end

  get '/stay/:id.json' do
  end

  get '/double/:id.json' do
  end

  get '/split/:id.json' do
  end

  get '/surrender/:id.json' do
  end
end
