require 'rspec'
require 'blackjack'

Dir.glob('lib/**/*.rb').each { |f| require File.absolute_path(f) }
