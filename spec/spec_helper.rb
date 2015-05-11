require 'rspec'
require 'pry'
require 'blackjack'

Dir.glob('lib/blackjack/**/*.rb').each { |f| require File.absolute_path(f) }
