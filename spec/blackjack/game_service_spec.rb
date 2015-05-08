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
    let(:ace) { Blackjack::Card.new(rank: :ace) }
    let(:deck) { Blackjack::Deck.new(ace, ace, ace, ace) }

    it 'marks the game as incompleted' do
      expect(game).to_not be_round_completed
    end

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

  context '#deal' do
    context 'When player gets blackjack' do
      let(:king) { Blackjack::Card.new(rank: :king) }
      let(:ace) { Blackjack::Card.new(rank: :ace) }
      let(:deck) { Blackjack::Deck.new(ace, king, king, king) }

      it 'ends the round' do
        expect_any_instance_of(Blackjack::GameService).to receive(:end_round)
        game.deal
      end
    end
  end

  context '#current_player_hand' do
    let(:five) { Blackjack::Card.new(rank: :'5') }
    let(:deck) { Blackjack::Deck.new(five, five, five, five, five, five) }

    context 'before splitting' do
      it 'points to the first hand' do
        expect(game.current_player_hand).to eq(game.player_hands.first)
      end
    end

    context 'after splitting and staying' do
      before { game.deal; game.split; game.stay }

      it 'points to the second hand' do
        expect(game.current_player_hand).to eq(game.player_hands.last)
      end
    end
  end

  context '#current_bet' do
    let(:five) { Blackjack::Card.new(rank: :'5') }
    let(:deck) { Blackjack::Deck.new(five, five, five, five, five, five) }
    let(:options) { { bet: 100 } }

    before { game.deal }

    context 'before splitting' do
      it 'returns bet from players hand' do
        expect(game.current_bet).to eq(100)
      end
    end

    context 'after splitting' do
      before { game.split }

      it 'sums bets from all hands' do
        expect(game.current_bet).to eq(200)
      end
    end
  end

  context '#hit' do
    let(:five) { Blackjack::Card.new(rank: :'5') }
    let(:available_cards) { [ five ] * 10 }
    let(:deck) { Blackjack::Deck.new(*available_cards) }

    before { game.deal }

    it 'provides players hand with one card' do
      expect { game.hit }.to change { game.current_player_hand.cards.size }.by(1)
    end

    context 'When there are more than 20 points in the second hand' do
      before do
        game.split
        game.stay
        4.times { |_| game.hit }
      end

      it 'refuses to hit' do
        expect { game.hit }.to raise_error(StandardError, "Can't take more cards")
      end
    end

    context 'For splitted hand' do
      before { game.split }

      context 'when current hand is first' do
        context 'if hand points becomes >= 21' do
          before { 3.times { |_| game.hit } }

          it 'switches current hand' do
            expect { game.hit }
              .to change { game.current_player_hand }
              .from(game.player_hands.first).to(game.player_hands.last)
          end
        end

        context 'if hand points is still < 21' do
          it 'provides current player hand with one more card' do
            expect { game.hit }
              .to change { game.current_player_hand.cards.size }
              .by(1)
          end
        end
      end

      context 'when current hand is second' do
        before { game.stay }

        context 'if hand points becomes >= 21' do
          before { 3.times { |_| game.hit } }

          it 'makes dealers turn and ends the round' do
            expect(game).to receive(:dealers_turn)
            expect(game).to receive(:end_round)
            game.hit
          end
        end

        context 'if hand points is still < 21' do
          it 'provides current player hand with one more card' do
            expect { game.hit }
              .to change { game.current_player_hand.cards.size }
              .by(1)
          end
        end
      end
    end
  end

  context '#stay' do
    let(:five) { Blackjack::Card.new(rank: :'5') }
    let(:deck) { Blackjack::Deck.new(five, five, five, five, five, five) }

    before { game.deal; game.split }

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

    before { game.deal }

    it 'takes cards from deck until points reaches 17 points' do
      expect_any_instance_of(Blackjack::Hand)
        .to receive(:take).exactly(2).times.and_call_original
      game.dealers_turn
    end
  end

  context '#split' do
    before { game.deal }

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

    before { game.deal }

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
    let(:six) { Blackjack::Card.new(rank: :'6') }
    let(:options) { { bet: 100, amount: 1000 } }

    before { game.deal }

    context 'when round ends after some turn' do
      let(:cards) { (1..3).map { king } + (1..6).map { six } }
      let(:deck) { Blackjack::Deck.new(*cards) }

      context 'when dealer busted' do
        before { game.stay }

        it 'gives money to the player' do
          expect(game.results).to include(player: [ :win ], total_amount: 1100)
          expect(game).to be_round_completed
        end
      end

      context 'when player busted' do
        before { game.hit }

        it 'takes money from player' do
          expect(game.results).to include(player: [ :loose ], total_amount: 900)
          expect(game).to be_round_completed
        end
      end
    end

    context 'when round ends after dealing' do
      before { game.end_round }

      context 'when dealer wins' do
        let(:deck) { Blackjack::Deck.new(king, six, king, king) }

        it 'takes money from player' do
          expect(game.results).to include(player: [ :loose ], total_amount: 900)
          expect(game).to be_round_completed
        end
      end

      context 'when player wins' do
        let(:deck) { Blackjack::Deck.new(king, king, king, six) }

        it 'gives money to the player' do
          expect(game.results).to include(player: [ :win ], total_amount: 1100)
          expect(game).to be_round_completed
        end
      end

      context 'dealers and players score are equal' do
        let(:deck) { Blackjack::Deck.new(king, king, king, king) }

        it 'gives money to the player' do
          expect(game.results).to include(player: [ :draw ], total_amount: 1000)
          expect(game).to be_round_completed
        end
      end
    end
  end
end
