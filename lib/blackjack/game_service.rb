class Blackjack::GameService
  class InvalidBet < StandardError
    def initialize
      super 'Bet cannot be more than total amount'
    end
  end

  class NotEnoughMoney < StandardError
    def initialize
      super 'You have no enough money to bet for this round'
    end
  end

  attr_reader :dealer_hand, :player_hands, :deck,
    :total_amount, :hand_number

  def initialize(deck: nil, options: {})
    # TODO: put bet into results
    @current_bet = options[:bet] || 50
    @total_amount = options[:amount] || 1000
    raise InvalidBet if @current_bet > @total_amount

    @results = { player: [], total_amount: @total_amount, completed: true }
    @hand_number = 0
    @deck = deck || Blackjack::Deck.new
    @player_hands = [ Blackjack::Hand::Nil.new ]
    @dealer_hand =  Blackjack::Hand::Nil.new
  end

  def deal(bet: nil)
    @current_bet = bet || @current_bet
    raise NotEnoughMoney if @current_bet > @total_amount

    @results = { player: [], total_amount: @total_amount, completed: false }
    @hand_number = 1
    @player_hands = [ Blackjack::Hand.new(cards: @deck.get(2), bet: @current_bet) ]
    dealer_cards = @deck.get(2)
    dealer_cards.last.hide
    @dealer_hand = Blackjack::Hand.new(cards: dealer_cards)

    # TODO: What about dealers blackjack insurance?
    # TODO: Pay 3/2 when player gets blackjack
    if current_player_hand.blackjack? || dealer_hand.blackjack?
      end_round
    end

  # TODO: Refactor dublication
  rescue Blackjack::Deck::NoMoreCards => err
    @results[:completed] = true
    @results[:player] << :draw
    @results[:message] = err.message
  end

  def results
    @results.merge({
      player_points: @player_hands.map(&:points),
      player_cards: @player_hands.map(&:to_s),
      dealer_points: dealer_hand.points,
      dealer_cards: dealer_hand.to_s,
    })
  end

  def current_player_hand
    player_hands[@hand_number - 1]
  end

  def current_bet
    @player_hands.map(&:bet).reduce(:+)
  end

  def hit
    if @hand_number > 2 || current_player_hand.points >= 21
      raise "Can't take more cards"
    end

    current_player_hand.take *deck.get(1)

    # TODO: Maybe extract this logic from hit
    if current_player_hand.points >= 21
      stay
    end
  rescue Blackjack::Deck::NoMoreCards => err
    @results[:completed] = true
    @results[:player] << :draw
    @results[:message] = err.message
  end

  def split
    if current_player_hand.splittable?
      # TODO: What if there is no money for the second bet?
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
    raise NotEnoughMoney if current_player_hand.bet * 2 > total_amount

    current_player_hand.bet *= 2
    hit
    stay unless round_completed?
  end

  def surrender
    if @player_hands.size > 1 || current_player_hand.size > 2
      raise 'You cannot surrender after splitting'
    else
      @results[:player] << :surrender
      @total_amount -= current_bet / 2
      @results[:total_amount] = @total_amount
      @results[:completed] = true
    end
  end

  def dealers_turn
    while @dealer_hand.reveal.points < 17
      @dealer_hand.take *deck.get(1)
    end
  rescue Blackjack::Deck::NoMoreCards => err
    @results[:completed] = true
    @results[:player] << :draw
    @results[:message] = err.message
  end

  def end_round
    @dealer_hand.reveal
    @player_hands.inject(@results) do |agg, hand|
      if hand.busted?
        agg[:player] << :loose
        @total_amount -= current_bet
      elsif @dealer_hand.busted?
        agg[:player] << :win
        @total_amount += current_bet
      elsif hand.points < @dealer_hand.points
        agg[:player] << :loose
        @total_amount -= current_bet
      elsif hand.points > @dealer_hand.points
        agg[:player] << :win
        @total_amount += current_bet
      else
        agg[:player] << :draw
      end
      agg[:total_amount] = @total_amount
      agg
    end

    @results[:completed] = true
  end

  def splitted?
    @player_hands.size == 2 ? true : false
  end

  def first_round?
    @player_hands.size == 1 && current_player_hand.size == 2
  end

  def round_completed?
    @results[:completed]
  end
end

