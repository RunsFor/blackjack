class Blackjack::AuthService
  NoGameProvided = Class.new(StandardError)
  NoMoreCardsInADeck = Class.new(StandardError)

  DEFAULT_RIGHTS = {
    status: true,
    game: true,
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

    raise NoGameProvided.new if game.nil?
    raise NoMoreCardsInADeck.new if game.deck.cards.empty?

    if game.round_completed?
      can :round
    else
      can :hit
      can :stay
      can :split if game.splittable?
      can :surrender if game.surrendable?
    end
  end

  def can?(action)
    @rights[action]
  end

  private

  def can(action)
    @rights[action] = true
  end
end
