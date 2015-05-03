require 'spec_helper'

describe Blackjack::Deck do
  subject(:deck) { described_class.new }

  it 'stores 52 cards' do
    expect(deck.cards.size).to eq(52)
  end

  # http://en.wikipedia.org/wiki/Standard_52-card_deck
  it 'has all cards from standard 52 card deck' do
    Blackjack::Card::COLORS.each do |color|
      Blackjack::Card::RANKS.each do |rank|
        expected_card = Blackjack::Card.new(color: color, rank: rank)
        expect(deck.cards).to include(expected_card)
      end
    end
  end

  it 'gets shuffled after each creation' do
    another_deck = described_class.new
    expect(
      (0..51).all? { |i| deck.cards[i] == another_deck.cards[i] }
    ).to be_falsey
  end

  context '#get' do
    it 'takes cards from the beginning of the deck' do
      first_cards = deck.cards[0..1]
      expect(deck.get(2)).to match_array(first_cards)
    end

    it 'removes cards after they were taken' do
      expect { deck.get(2)}.to change { deck.size }.by(-2)
    end
  end
end
