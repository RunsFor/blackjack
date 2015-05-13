require 'rest-client'
require 'json'
require 'highline/import'
require 'pry'
require 'awesome_print'

# NOTE: --host=localhost --port=9292
def parse_args(options = [])
  options.inject({}) do |args, opt|
    key, value = opt.split('=')
    args[key] = value
    args
  end
end

HOST = parse_args(ARGV)['--host'] || 'localhost'
PORT = parse_args(ARGV)['--port'] || '9292'
URL = "http://#{HOST}:#{PORT}/"

def start_game
  bet = 50
  cmd = ""
  while (cmd != 'q') do
    question = "Enter command?" \
      "(e - exit; stat - :status; delete - delete :game;" \
      " c - create :game; set 10 - set bet; r - create :round; h - :hit;" \
      " s - :stay; sp - :split; d - :double; sur - :surrender)"

    cmd = ask question

    response = case cmd
               when 'e', 'exit'
                 break
               when 'delete'
                 delete :game
               when 'c', 'create'
                 post :game, bet: bet
               when 'r', 'round'
                 post :round, bet: bet
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
               when /^set\s\d*$/
                 bet = cmd.split[1].to_i
                 next
               else next
               end

    ap parse_json(response)
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
rescue => err
  err.response.body
end

def parse_json(result)
  JSON.parse result
end

start_game
