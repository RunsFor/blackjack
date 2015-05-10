require 'json'
require 'sinatra'

class Blackjack::Api < Sinatra::Base
  attr_reader :filename, :storage, :game

  def initialize
    @filename = 'blackjack.txt'
    @storage = Blackjack::GameStorage.new(@filename)

    super
  end

  before do
    if request.path =~ /(round|hit|stay|double|split|surrender)/
      @game = storage.first
      unless @game.is_a?(Blackjack::GameService)
        raise "There are no active games right now!"
      end
    end
  end

  get '/status.json' do
    content_type :json
    { status: :ok, message: nil }.to_json
  end

  # TODO: Set bet and total amount
  post '/game.json' do
    content_type :json
    deck = Blackjack::Deck.new
    game = Blackjack::GameService.new(deck: deck)
    storage.store(game)
    { status: 'ok' }.to_json
  end

  delete '/game.json' do
    content_type :json
    storage.delete_all
    { status: 'ok' }.to_json
  end

  # TODO: Set bet and total amount
  post '/round.json' do
    content_type :json

    game.deal

    storage.store(game)

    game.results.to_json
  end

  post '/hit.json' do
    content_type :json

    game.hit

    storage.store(game)

    game.results.to_json
  end

  post '/stay.json' do
    content_type :json

    game.stay

    storage.store(game)

    game.results.to_json
  end

  post '/double.json' do
    content_type :json

    game.double
    storage.store(game)

    game.results.to_json
  end

  post '/split.json' do
    content_type :json

    game.split
    storage.store(game)

    game.results.to_json
  end

  post '/surrender.json' do
    content_type :json

    game.surrender
    storage.store(game)

    game.results.to_json
  end
end
