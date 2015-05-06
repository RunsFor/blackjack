class Blackjack::Deck
  attr_reader :cards

  def initialize(*cards)
    @cards = cards.empty? ? (0..51).map { |i| Blackjack::Card[i] }.shuffle : cards
  end

  def size
    cards.size
  end

  def get(num = 0)
    cards.shift(num)
  end
end

