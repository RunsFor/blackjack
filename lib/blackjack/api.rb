require 'json'
require 'sinatra'
require 'blackjack/auth_service'
require 'pry'

class Blackjack::Api < Sinatra::Base
  AUTH_ACTIONS = %w(round hit stay double split surrender)

  attr_reader :filename, :storage, :game

  def initialize
    @filename = 'blackjack.txt'
    @storage = Blackjack::GameStorage.new(@filename)

    super
  end

  before do
    content_type :json

    matchdata = /(?<action>#{AUTH_ACTIONS.join('|')})/.match(request.path)
    action = matchdata && matchdata[:action]
    if AUTH_ACTIONS.include?(action)
      @game = storage.first
      @auth = begin
                Blackjack::AuthService.new(@game)
              rescue => err
                halt 404, { status: :fail, message: err.message }.to_json
              end
      unless @auth.can?(action)
        halt 403, {
          status: :fail,
          message: 'Method forbidden. Ask :status for available actions',
        }.to_json
      end
    end
  end

  get '/status.json' do
    content_type :json
    game = storage.first

    response = { status: :ok, message: nil }

    auth = begin
             Blackjack::AuthService.new(game)
           rescue => err
             response[:message] = err.message
             nil
           end
    authorized_actions = auth && auth.rights.select{ |_,v| v }.keys

    response[:games_available] = storage.all.size
    response[:available_actions] = [ :status, :game]
    response[:available_actions].push(*authorized_actions)
    response.to_json
  end

  # TODO: Set bet and total amount
  post '/game.json' do
    deck = Blackjack::Deck.new
    game = Blackjack::GameService.new(deck: deck)
    storage.store(game)
    { status: 'ok' }.to_json
  end

  delete '/game.json' do
    storage.delete_all
    { status: 'ok' }.to_json
  end

  # TODO: Set bet and total amount
  post '/round.json' do
    game.deal

    storage.store(game)

    game.results.to_json
  end

  post '/hit.json' do
    game.hit

    storage.store(game)

    game.results.to_json
  end

  post '/stay.json' do
    game.stay

    storage.store(game)

    game.results.to_json
  end

  # TODO: Why forbidden after split?
  post '/double.json' do
    game.double
    storage.store(game)

    game.results.to_json
  end

  post '/split.json' do
    game.split
    storage.store(game)

    game.results.to_json
  end

  post '/surrender.json' do
    game.surrender
    storage.store(game)

    game.results.to_json
  end
end
