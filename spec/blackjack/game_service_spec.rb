require 'spec_helper'

describe Blackjack::GameService do
  subject(:game) { described_class.new(deck: deck, options: options) }

  let(:deck) { nil }
  let(:options) { {} }

  it { is_expected.to respond_to(:hit) }
  it { is_expected.to respond_to(:stay) }
  it { is_expected.to respond_to(:double) }
  it { is_expected.to respond_to(:split) }
  it { is_expected.to respond_to(:surrender) }

  describe 'defaults' do
    it 'bet is 50, total amount is 1000' do
      expect(game.current_bet).to eq(50)
      expect(game.total_amount).to eq(1000)
    end

    context 'When options provided' do
      let(:options) { { bet: 100, amount: 2000 } }

      it 'bet and amount are settable' do
        expect(game.current_bet).to eq(100)
        expect(game.total_amount).to eq(2000)
      end

      context 'When bet is more then total amount' do
        let(:options) { { bet: 5000, amount: 1000 } }

        it 'raises an exception' do
          expect { game }.to raise_error
        end
      end
    end
  end

  context '#hit' do
    # TODO: Sometimes this test failed. Possibly because of blackjack
    it 'provides players hand with one card' do
      expect { game.hit }.to change { game.player_hand.cards.size }.by(1)
    end

    context 'When there are more than 20 points in the hand' do
      let(:ace_spades) { Blackjack::Card.new(rank: :ace, color: :spades) }
      let(:king_spades) { Blackjack::Card.new(rank: :king, color: :spades) }

      let(:deck) { Blackjack::Deck.new(ace_spades, king_spades) }

      it 'refuses to hit' do
        expect { game.hit }.to raise_error(StandardError, "Can't take more cards")
      end
    end
  end

  context '#stay' do
    let(:five) { Blackjack::Card.new(rank: :'5') }
    let(:deck) { Blackjack::Deck.new(five, five, five, five, five, five) }

    before { game.split }

    context 'when playing with last hand of the player' do
      before { game.stay }

      it 'evaluates dealears turn and ends the round' do
        expect(game).to receive(:dealers_turn).once
        expect(game).to receive(:end_round).once
        game.stay
      end
    end

    context 'when playing with first hand of the player' do
      it 'increasing hand_number' do
        expect(game).to_not receive(:dealers_turn)
        expect(game).to_not receive(:end_round)
        expect { game.stay }.to change { game.hand_number }.by(1)
      end
    end
  end

  context '#dealers_turn' do
    let(:five) { Blackjack::Card.new(rank: :'5') }
    let(:deck) { Blackjack::Deck.new(five, five, five, five, five, five) }

    it 'takes cards from deck until points reaches 17 points' do
      expect_any_instance_of(Blackjack::Hand)
        .to receive(:take).exactly(2).times.and_call_original
      game.dealers_turn
    end
  end

  context '#split' do
    context 'when card have the same rank' do
      let(:five) { Blackjack::Card.new(rank: :'5') }
      let(:deck) { Blackjack::Deck.new(five, five, five, five, five, five) }

      it 'Splits hands into two' do
        expect { game.split }.to change { game.player_hands.size }.from(1).to(2)
      end
    end

    context 'when it is not splittable' do
      it 'raises an exception' do
        expect_any_instance_of(Blackjack::Hand).to receive(:splittable?) { false }
        expect { game.split }.to raise_error
      end
    end
  end

  context '#surrender' do
    let(:options) { { bet: 100 } }
    it 'returns half of the bet to the player and ends the round' do
      expect(game).to receive(:end_round)
      expect { game.surrender }.to change { game.total_amount }.by(-50)
    end

    context 'when there is more than 1 hand' do
      let(:five) { Blackjack::Card.new(rank: :'5') }
      let(:deck) { Blackjack::Deck.new(five, five, five, five, five, five) }

      before { game.split }

      it 'raises an exception' do
        expect { game.surrender }.to raise_error
      end
    end
  end

  context '#end_round' do
    let(:king) { Blackjack::Card.new(rank: :king) }
    let(:queen) { Blackjack::Card.new(rank: :queen) }
    let(:ace) { Blackjack::Card.new(rank: :ace) }
    let(:options) { { bet: 100, amount: 1000 } }

    context 'when dealer wins' do
      let(:deck) { Blackjack::Deck.new(king, queen, king, ace) }

      it 'takes money from player' do
        result = game.end_round
        expect(result).to include(player: [ :loose ], total_amount: 900)
      end
    end

    context 'when player wins' do
      let(:deck) { Blackjack::Deck.new(king, ace, king, queen) }

      it 'gives money to the player' do
        result = game.end_round
        expect(result).to include(player: [ :win ], total_amount: 1100)
      end
    end

    context 'dealers and players score are equal' do
      let(:deck) { Blackjack::Deck.new(king, king, king, queen) }

      it 'gives money to the player' do
        result = game.end_round
        expect(result).to include(player: [ :draw ], total_amount: 1000)
      end
    end
  end
end
