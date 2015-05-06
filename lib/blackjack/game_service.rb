class Blackjack::GameService
  attr_reader :dealer_hand, :player_hands, :deck, :current_bet, :total_amount

  def initialize(deck: nil, options: {})
    @current_bet = options[:bet] || 50
    @total_amount = options[:amount] || 1000
    raise "Bet cannot be more than total amount" if @current_bet > @total_amount

    @deck = deck || Blackjack::Deck.new
    @player_hands = [ Blackjack::Hand.new(cards: @deck.get(2)) ]
    @dealer_hand = Blackjack::Hand.new(cards: @deck.get(2))
  end

  def player_hand
    player_hands.first
  end

  # TODO: Improve to work with splitted hands
  # TODO: What if card in the deck ends?
  def hit
    raise "Can't take more cards" if player_hand.points >= 21
    player_hand.take *deck.get(1)
  end

  def split
    # Split hand into two hands
  end

  def stay
    dealers_turn
    end_round
  end

  def double
    raise "Can't take more cards" if player_hand.points >= 21
    @current_bet *= 2
    hit
    stay
  end

  def surrender
    @total_amount -= @current_bet / 2
    end_round
  end

  def dealers_turn
    while @dealer_hand.points < 17
      @dealer_hand.take *deck.get(1)
    end
  end

  def end_round
    @player_hands.inject({ player: [], total_amount: @total_amount }) do |agg, hand|
      if hand.points > @dealer_hand.points
        agg[:player] << :win
        agg[:total_amount] += @current_bet
      elsif player_hand.points < @dealer_hand.points
        agg[:player] << :loose
        agg[:total_amount] -= @current_bet
      else
        agg[:player] << :draw
      end
      agg
    end
  end
end

