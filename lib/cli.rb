require 'rest-client'
require 'json'
require 'highline/import'
require 'pry'
require 'awesome_print'

HOST = "localhost"
PORT = "9292"
URL = "http://#{HOST}:#{PORT}/"

def start_game
  cmd = ""
  while (cmd != 'q') do
    question = "Enter command?" \
      "(e - exit; stat - status; delete - delete game;" \
      " c - create game; r - create round; h - hit;" \
      " s - stay; sp - split; d - double; sur - surrender)"

    cmd = ask question

    result = case cmd
             when 'e', 'exit'
               break
             when 'delete'
               delete :game
             when 'c', 'create'
               post :game
             when 'r', 'round'
               post :round
             when 'h', 'hit'
               post :hit
             when 's', 'stay'
               post :stay
             when 'sp', 'split'
               post :split
             when 'd', 'double'
               post :double
             when 'sur', 'surrender'
               post :surrender
             when 'stat', 'status'
               get :status
             end

    ap parse_json(result)
  end
end

def delete(action = :game, options = {})
  request :delete, action, options
end

def post(action, options = {})
  request :post, action, options
end

def get(action = :status, options = {})
  request :get, action, options
end

def request(method, action, options = {})
  params = { params: options, content_type: :json, accept: :json }
  RestClient.send(method, URL + "#{action}.json", params)
end

def parse_json(result)
  JSON.parse result
end

start_game
