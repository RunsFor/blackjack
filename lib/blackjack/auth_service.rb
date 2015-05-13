class Blackjack::AuthService
  class NoGameProvided < StandardError
    def initialize
      super 'No game found'
    end
  end

  class NoMoreCardsInADeck < StandardError
    def initialize
      super 'No more cards left in the deck'
    end
  end

  DEFAULT_RIGHTS = {
    round: false,
    hit: false,
    stay: false,
    double: false,
    split: false,
    surrender: false,
  }.freeze

  attr_reader :game, :rights

  def initialize(game)
    @game = game
    @rights = DEFAULT_RIGHTS.dup || {}

    raise NoGameProvided if game.nil?
    raise NoMoreCardsInADeck if game.deck.cards.empty?

    if game.round_completed?
      can :round
    else
      can :hit
      can :stay
      can :split if game.first_round? && game.current_player_hand.splittable?
      can :surrender if game.first_round?
      can :double if game.first_round?
    end
  end

  def can?(action)
    @rights[action.to_sym]
  end

  private

  def can(action)
    @rights[action] = true
  end
end
