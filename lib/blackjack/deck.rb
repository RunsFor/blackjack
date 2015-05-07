require 'forwardable'

class Blackjack::Deck
  extend Forwardable

  attr_reader :cards

  def initialize(*cards)
    @cards = cards.empty? ? (0..51).map { |i| Blackjack::Card[i] }.shuffle : cards
  end

  def_delegator :@cards, :size
  def_delegator :@cards, :shift, :get
end

