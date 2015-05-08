class Blackjack::Card
  RANKS = %i(ace 2 3 4 5 6 7 8 9 10 jack queen king)
  COLORS = %i(clubs diamonds hearts spades)

  attr_reader :color, :rank

  def self.[](index)
    col = index % 13
    row = index / 13
    new(color: COLORS[row], rank: RANKS[col])
  end

  def self.random
    new
  end

  # TODO: Add #to_s method
  def initialize(color: nil, rank: nil, hidden: false)
    @color = color || COLORS.sample
    @rank = rank || RANKS.sample
    @hidden = hidden
  end

  def hidden?
    @hidden
  end

  def hide
    @hidden = true
    self
  end

  def reveal
    @hidden = false
    self
  end

  def <=>(card)
    Blackjack::Card::RANKS.index(card.rank) <=> Blackjack::Card::RANKS.index(rank)
  end

  def ==(card)
    card.kind_of?(Blackjack::Card) &&
      rank == card.rank &&
      color == card.color
  end

  # TODO: Maybe refactor
  def ace?
    rank == :ace
  end

  def two?
    rank == :'2'
  end

  def three?
    rank == :'3'
  end

  def four?
    rank == :'4'
  end

  def five?
    rank == :'5'
  end

  def six?
    rank == :'6'
  end

  def seven?
    rank == :'7'
  end

  def eight?
    rank == :'8'
  end

  def nine?
    rank == :'9'
  end

  def ten?
    rank == :'10'
  end

  def jack?
    rank == :jack
  end

  def queen?
    rank == :queen
  end

  def king?
    rank == :king
  end

  def clubs?
    color == :clubs
  end

  def hearts?
    color == :hearts
  end

  def diamonds?
    color == :diamonds
  end

  def spades?
    color ==:spades
  end

  def to_json
    result = hidden? ? { color: '***', rank: '***' } : { color: color, rank: rank }
    result.to_json
  end
end

