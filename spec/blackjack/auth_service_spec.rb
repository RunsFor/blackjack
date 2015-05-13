require 'spec_helper'

describe Blackjack::AuthService do
  subject(:auth) { described_class.new(game) }

  let(:game) { Blackjack::GameService.new(deck: deck, options: options) }
  let(:deck) { Blackjack::Deck.new }
  let(:options) { {} }

  context '#authorize!' do
    context 'when authorized' do
      it 'returns true' do
        expect(auth).to receive(:can?).with(:game) { true }
        expect(auth.authorize!(:game)).to eq(true)
      end
    end

    context 'when unauthorized' do
      it 'raises exception' do
        expect(auth).to receive(:can?).with(:game) { false }
        expect { auth.authorize!(:game) }
          .to raise_error(Blackjack::AuthService::UnauthorizedAction)
      end
    end
  end

  context 'When no game provided' do
    let(:game) { nil }

    it 'raises error' do
      expect { auth }.to raise_error(Blackjack::AuthService::NoGameProvided)
    end
  end

  context 'When no more cards in a deck' do
    let(:deck) { Blackjack::Deck.new(cards: []) }

    it 'raises error' do
      expect { auth }.to raise_error(Blackjack::AuthService::NoMoreCardsInADeck)
    end
  end

  context 'when round completed' do
    before { expect(game).to receive(:round_completed?) { true } }

    it 'allows :round, :game, :status' do
      expect(auth.can?(:round)).to eq(true)
    end

    it 'rejects :hit, :stay, :split, :surrender' do
      expect(auth.can?(:hit)).to eq(false)
      expect(auth.can?(:stay)).to eq(false)
      expect(auth.can?(:split)).to eq(false)
      expect(auth.can?(:surrender)).to eq(false)
    end
  end

  context 'when round is not completed' do
    before { expect(game).to receive(:round_completed?) { false } }

    it 'allows :hit, :stay, :game, :status' do
      expect(auth.can?(:hit)).to eq(true)
      expect(auth.can?(:stay)).to eq(true)
    end

    it 'rejects :round, :split' do
      expect(auth.can?(:round)).to eq(false)
      expect(auth.can?(:split)).to eq(false)
      expect(auth.can?(:surrender)).to eq(false)
    end

    context 'when it is a first round' do
      before { game.deal }

      it 'allows :surrender, :double' do
        expect(auth.can?(:surrender)).to eq(true)
        expect(auth.can?(:double)).to eq(true)
      end

      context 'when two same cards in a deck' do
        let(:ace) { Blackjack::Card.new(rank: :ace) }
        let(:deck) { Blackjack::Deck.new(cards: 5.times.map { ace }) }

        it 'allows :split' do
          expect(auth.can?(:split)).to eq(true)
        end
      end
    end
  end
end
