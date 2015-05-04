class Blackjack::Play
  attr_reader :dealer_hand, :player_hands

  def initialize
    deck = Blackjack::Deck.new
    @dealer_hand = Blackjack::Hand.new(deck: deck)
    @player_hands = [ Blackjack::Hand.new(deck: deck) ]
  end

  def player_hand
    player_hands.first
  end
end
