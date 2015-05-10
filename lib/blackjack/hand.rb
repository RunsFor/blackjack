require 'forwardable'

class Blackjack::Hand
  extend Forwardable

  attr_accessor :bet
  attr_reader :cards

  def initialize(cards: [], bet: 0)
    raise 'Array of cards is expected' unless cards.is_a?(Array)
    @cards = cards || []
    @bet = bet
  end

  def_delegator :@cards, :push, :take
  delegate %i(size empty?) => :@cards

  def points(exclude: [ :hidden? ])
    cards = exclude.inject(@cards.sort) { |res, meth| res.reject(&meth) }
    sum = cards.map(&:points).reduce(&:+) || 0
    aces = cards.select(&:ace?).size

    while (sum > 21 && aces > 0) do
      aces -= 1
      sum -= 10
    end

    sum
  end

  def reveal
    cards.each(&:reveal)
    self
  end

  def blackjack?
    size == 2 && points(exclude: []) == 21
  end

  def splittable?
    cards.size == 2 && cards.first.rank == cards.last.rank
  end

  def busted?
    points > 21 ? true : false
  end

  def to_s
    cards.map(&:to_s)
  end

  def to_json(*args)
    cards.to_json(*args)
  end
end
