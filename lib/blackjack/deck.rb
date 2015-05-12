require 'forwardable'

class Blackjack::Deck
  extend Forwardable

  attr_reader :cards

  def initialize(cards: nil)
    @cards = cards.nil? ? (0..51).map { |i| Blackjack::Card[i] }.shuffle : cards
  end

  def_delegator :@cards, :size

  def get(num)
    cards = @cards.shift(num)
    raise 'No more cards in the deck' if cards.size != num
    cards
  end
end

