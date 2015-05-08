require 'spec_helper'

describe Blackjack::Hand do
  subject(:hand) { described_class.new(cards: cards, bet: bet) }

  let(:cards) { [] }
  let(:bet) { 0 }

  context '.new' do
    let(:ace_spades) { Blackjack::Card.new(color: :spades, rank: :ace) }
    let(:ten_clubs) { Blackjack::Card.new(color: :clubs, rank: :ten) }

    it { is_expected.to be_empty }

    context 'When bet provided' do
      let(:bet) { 100 }

      it 'stores hands bet' do
        expect(hand.bet).to eq(100)
      end

      it 'updates bet for existing hand' do
        hand.bet = 200
        expect(hand.bet).to eq(200)
      end
    end

    context 'When cards provided' do
      let(:cards) { [ ace_spades, ten_clubs ] }

      it 'takes cards as arguments' do
        expect(hand.cards).to contain_exactly(ace_spades, ten_clubs)
      end
    end

    context 'When cards is not an instance of an Array' do
      let(:cards) { ace_spades }

      it 'raises an error' do
        expect { hand }.to raise_error
      end
    end
  end

  context '#splittable?' do
    let(:ace_spades) { Blackjack::Card.new(rank: :ace, color: :spades) }
    let(:ace_clubs) { Blackjack::Card.new(rank: :ace, color: :clubs) }
    let(:two_spades) { Blackjack::Card.new(rank: :'2', color: :spades) }

    context 'When two cards has the same rank' do
      let(:cards) { [ ace_spades, ace_clubs ] }
      it { is_expected.to be_splittable }
    end

    context 'When two cards has different ranks' do
      let(:cards) { [ ace_spades, two_spades ] }
      it { is_expected.to_not be_splittable }
    end

    context 'When there are more than two cards' do
      let(:cards) { [ ace_spades, two_spades, ace_clubs ] }
      it { is_expected.to_not be_splittable }
    end
  end

  context '#take' do
    let(:ace_spades) { Blackjack::Card.new(rank: :ace, color: :spades) }

    it 'takes a card' do
      expect { hand.take(ace_spades) }
        .to change { hand.size }.by(1)
        .and change { hand.points }.by(11)
    end
  end

  context '#reveal' do
    let(:hidden_ace) { Blackjack::Card.new(rank: :ace, hidden: true) }
    let(:king) { Blackjack::Card.new(rank: :king) }
    let(:cards) { [ king, hidden_ace ] }

    it 'reveals all cards' do
      expect { hand.reveal }
        .to change { hand.points }
        .from(10).to(21)
    end

    it 'returns self' do
      expect(hand.reveal).to be_a_kind_of(Blackjack::Hand)
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
    let(:hidden_card) { Blackjack::Card.new(hidden: true) }

    context 'when hidden' do
      context 'when all cards are hidden' do
        let(:cards) { [ hidden_card ] }

        it 'returns 0' do
          expect(hand.points).to eq(0)
        end
      end
      context 'when some of cards are hidden' do
        let(:cards) { [ jack, hidden_card ] }

        it 'return sum of not hidden cards' do
          expect(hand.points).to eq(10)
        end
      end
    end

    context 'ace and king' do
      let(:cards) { [ ace, king ] }

      it '21' do
        expect(hand.points).to eq(21)
      end
    end

    context 'queen and jack' do
      let(:cards) { [ queen, jack ] }

      it '20' do
        expect(hand.points).to eq(20)
      end
    end

    context 'two, three, four, five and six' do
      let(:cards) { [ two, three, four, five, six ] }

      it '20' do
        expect(hand.points).to eq(20)
      end
    end

    context 'nine, king and two aces' do
      let(:cards) { [ nine, ace, ace, king ] }

      it '21' do
        expect(hand.points).to eq(21)
      end
    end
  end

  context '#blackjack?' do
    let(:hidden_ace) { Blackjack::Card.new(rank: :ace, hidden: true) }
    let(:blackjack) { Blackjack::Card.new(rank: :jack, color: :spades) }
    let(:cards) { [ blackjack, hidden_ace ] }

    it 'ignores hidden cards' do
      expect(hand).to be_blackjack
    end
  end

  context '#busted?' do
    context 'When 21 < points' do
      before { expect(hand).to receive(:points) { 22 } }
      it { is_expected.to be_busted }
    end

    context 'When points <= 21' do
      before { expect(hand).to receive(:points) { 21 } }
      it { is_expected.to_not be_busted }
    end
  end
end
