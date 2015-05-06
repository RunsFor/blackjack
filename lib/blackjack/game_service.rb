class Blackjack::GameService
  attr_reader :dealer_hand, :player_hands, :deck, :current_bet,
    :total_amount, :hand_number


  def initialize(deck: nil, options: {})
    # TODO: Improve to work with splitted bets. Maybe put bet into Hand
    @current_bet = options[:bet] || 50
    @total_amount = options[:amount] || 1000
    raise "Bet cannot be more than total amount" if @current_bet > @total_amount

    @deck = deck || Blackjack::Deck.new
    @hand_number = 1
    @player_hands = [ Blackjack::Hand.new(cards: @deck.get(2)) ]
    @dealer_hand = Blackjack::Hand.new(cards: @deck.get(2))
  end

  # TODO: Maybe switch to current_hand
  def player_hand
    player_hands.first
  end

  # TODO: Improve to work with splitted hands
  # TODO: What if card in the deck ends?
  # TODO: When reaches 21, automatically stay
  # TODO: When busting, automatically ends the round
  def hit
    raise "Can't take more cards" if player_hand.points >= 21
    player_hand.take *deck.get(1)
  end

  def split
    if player_hand.splittable?
      @player_hands = [
        Blackjack::Hand.new(cards: player_hand.cards.first),
        Blackjack::Hand.new(cards: player_hand.cards.last),
      ]
    else
      raise "You cannot split this hand"
    end
  end

  def stay
    if @hand_number == @player_hands.size
      dealers_turn
      end_round
    else
      @hand_number += 1
    end
  end

  def double
    raise "Can't take more cards" if player_hand.points >= 21
    @current_bet *= 2
    hit
    stay
  end

  def surrender
    if @player_hands.size > 1
      raise 'You cannot surrender after splitting'
    else
      @total_amount -= @current_bet / 2
      end_round
    end
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

