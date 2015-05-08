app_dirname = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift app_dirname

require 'blackjack'

Dir.glob(File.join(app_dirname, "blackjack/**/*.rb")).each { |f| require f }

run Blackjack::Api

