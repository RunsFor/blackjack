require 'spec_helper'

describe Blackjack::Card do
  subject(:card) { describe.new }

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

  describe '#hidden?' do
    context 'when hidden' do
      subject { described_class.new(hidden: true).hidden? }
      it { is_expected.to eq(true) }
    end

    context 'when not hidden' do
      subject { described_class.new.hidden? }
      it { is_expected.to eq(false) }
    end
  end

  describe '#hide' do
    subject { described_class.new(hidden: false).hide }
    it { is_expected.to be_hidden }
  end

  describe '#reveal' do
    subject { described_class.new(hidden: true).reveal }
    it { is_expected.to_not be_hidden }
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

  context '#to_json' do
    context 'when hidden' do
      subject(:card) { described_class.new(color: :spades, rank: :ace, hidden: true) }

      it 'return JSON representatino of the object' do
        expect(card.to_json).to eq({ color: '***', rank: '***' }.to_json)
      end
    end

    context 'when no hidden' do
      subject(:card) { described_class.new(color: :spades, rank: :ace) }

      it 'return JSON representatino of the object' do
        expect(card.to_json).to eq({ color: :spades, rank: :ace }.to_json)
      end
    end
  end
end
