class Blackjack::Hand

  attr_reader :cards

  def initialize(*cards)
    @cards = cards.empty? ? Blackjack::Deck.new.get(2) : cards
  end

  def sort
    @cards.sort do |a, b|
      Blackjack::Card::RANKS.index(b.rank) <=> Blackjack::Card::RANKS.index(a.rank)
    end
  end

  def points
    sort.inject(0) do |sum, card|
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
end
