require 'spec_helper'
require 'byebug'

describe Blackjack::Hand do
  subject(:hand) { described_class.new }

  context '.new' do
    it 'defaults to two random cards' do
      expect(hand.cards.size).to eq(2)
    end

    context 'with arguments' do
      subject(:deck) { described_class.new(ace_spades, ten_clubs) }

      let(:ace_spades) { Blackjack::Card.new(color: :spades, rank: :ace) }
      let(:ten_clubs) { Blackjack::Card.new(color: :clubs, rank: :ten) }

      it 'takes cards as arguments' do
        expect(deck.cards).to contain_exactly(ace_spades, ten_clubs)
      end
    end
  end

  context '#points' do
    let(:ace) { Blackjack::Card.new(rank: :ace) }
    let(:two) { Blackjack::Card.new(rank: :'2') }
    let(:three) { Blackjack::Card.new(rank: :'3') }
    let(:four) { Blackjack::Card.new(rank: :'4') }
    let(:five) { Blackjack::Card.new(rank: :'5') }
    let(:six) { Blackjack::Card.new(rank: :'6') }
    let(:seven) { Blackjack::Card.new(rank: :'7') }
    let(:eight) { Blackjack::Card.new(rank: :'8') }
    let(:nine) { Blackjack::Card.new(rank: :'9') }
    let(:ten) { Blackjack::Card.new(rank: :'10') }
    let(:king) { Blackjack::Card.new(rank: :king) }
    let(:queen) { Blackjack::Card.new(rank: :queen) }
    let(:jack) { Blackjack::Card.new(rank: :jack) }
    let(:cards) { [] }

    subject(:deck) { described_class.new(*cards) }

    context 'ace and king' do
      let(:cards) { [ ace, king ] }

      it '21' do
        expect(deck.points).to eq(21)
      end
    end

    context 'queen and jack' do
      let(:cards) { [ queen, jack ] }

      it '20' do
        expect(deck.points).to eq(20)
      end
    end

    context 'two, three, four, five and six' do
      let(:cards) { [ two, three, four, five, six ] }

      it '20' do
        expect(deck.points).to eq(20)
      end
    end

    context 'nine, king and two aces' do
      let(:cards) { [ nine, ace, ace, king ] }

      it '21' do
        expect(deck.points).to eq(21)
      end
    end
  end
end
