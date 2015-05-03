class Blackjack::Deck
  attr_reader :cards

  def initialize
    @cards = (0..51).map { |i| Blackjack::Card[i] }.shuffle
  end
end

