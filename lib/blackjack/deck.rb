require 'forwardable'

class Blackjack::Deck
  class NoMoreCards < StandardError
    def initialize
      super 'No more cards in a deck'
    end
  end

  extend Forwardable

  attr_reader :cards

  def initialize(cards: nil)
    @cards = cards.nil? ? (0..51).map { |i| Blackjack::Card[i] }.shuffle : cards
  end

  def_delegator :@cards, :size

  def get(num)
    cards = @cards.shift(num)
    raise NoMoreCards if cards.size != num
    cards
  end
end

