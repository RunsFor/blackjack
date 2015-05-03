require 'spec_helper'

describe Blackjack::Card do
  context '.[]' do
    it 'returns card by its index' do
      expect(described_class[0]).to be_ace
      expect(described_class[0]).to be_clubs
      expect(described_class[12]).to be_king
      expect(described_class[12]).to be_clubs
      expect(described_class[26]).to be_ace
      expect(described_class[26]).to be_hearts
    end
  end

  context '.random' do
    it 'generates appropriate card' do
      card = described_class.random
      expect(Blackjack::Card::RANKS).to include(card.rank)
      expect(Blackjack::Card::COLORS).to include(card.color)
    end
  end

  context '#==' do
    let(:card1) { described_class.new(color: :spades, rank: :'7') }
    let(:card2) { described_class.new(color: :hearts, rank: :'7') }
    let(:card3) { described_class.new(color: :spades, rank: :'7') }

    it 'compares two cards' do
      expect(card1).to eq(card3)
      expect(card1).to_not eq(card2)
      expect(card2).to_not eq(card3)
    end
  end
end
