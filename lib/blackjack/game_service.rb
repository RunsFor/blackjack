class Blackjack::GameService
  attr_reader :dealer_hand, :player_hands, :deck,
    :total_amount, :hand_number, :results

  def initialize(deck: nil, options: {})
    @current_bet = options[:bet] || 50
    @total_amount = options[:amount] || 1000
    raise "Bet cannot be more than total amount" if @current_bet > @total_amount

    @results = { player: [], total_amount: @total_amount }
    @completed = false
    @deck = deck || Blackjack::Deck.new
    @hand_number = 0
    @player_hands = [  ]
    @dealer_hand =  nil
  end

  def deal
    @hand_number = 1
    @player_hands = [ Blackjack::Hand.new(cards: @deck.get(2), bet: @current_bet) ]
    @dealer_hand = Blackjack::Hand.new(cards: @deck.get(2))

    # TODO: What about dealers blackjack insurance?
    if player_blackjack? || dealer_blackjack?
      end_round
    end
  end

  def current_player_hand
    player_hands[@hand_number - 1]
  end

  def current_bet
    @player_hands.empty? ? @current_bet : @player_hands.map(&:bet).reduce(:+)
  end

  def hit
    if @hand_number > 2 || current_player_hand.points >= 21
      raise "Can't take more cards"
    end

    cards = deck.get(1)
    if cards.empty?
      raise 'No more cards in the deck'
    else
      current_player_hand.take *cards
    end

    if current_player_hand.points >= 21
      stay
    end
  end

  def split
    if current_player_hand.splittable?
      bet = current_player_hand.bet
      @player_hands = [
        Blackjack::Hand.new(cards: [ current_player_hand.cards.first ], bet: bet),
        Blackjack::Hand.new(cards: [ current_player_hand.cards.last ], bet: bet),
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
    raise "Can't take more cards" if current_player_hand.points >= 21
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
    @player_hands.inject(@results) do |agg, hand|
      if hand.points > @dealer_hand.points
        agg[:player] << :win
        agg[:total_amount] += @current_bet
      elsif hand.points < @dealer_hand.points
        agg[:player] << :loose
        agg[:total_amount] -= @current_bet
      else
        agg[:player] << :draw
      end
      agg
    end

    @completed = true
  end

  def round_completed?
    @completed
  end

  private

  def player_blackjack?
    current_player_hand.cards.size == 2 && current_player_hand.points == 21
  end

  def dealer_blackjack?
    @dealer_hand.cards.size == 2 && @dealer_hand.points == 21
  end
end

