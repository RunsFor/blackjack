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
  def_delegator :@cards, :empty?

  # TODO: Maybe refactor
  def points
    @cards.sort.inject(0) do |sum, card|
      case
      when card.two?
        sum += 2
      when card.three?
        sum += 3
      when card.four?
        sum += 4
      when card.five?
        sum += 5
      when card.six?
        sum += 6
      when card.seven?
        sum += 7
      when card.eight?
        sum += 8
      when card.nine?
        sum += 9
      when card.king?, card.queen?, card.jack?, card.ten?
        sum += 10
      when card.ace?
        sum += sum > 10 ? 1 : 11
      end

      sum
    end
  end

  def splittable?
    cards.size == 2 && cards.first.rank == cards.last.rank
  end
end
