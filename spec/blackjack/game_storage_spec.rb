require 'spec_helper'

describe Blackjack::GameStorage do
  subject(:storage) { described_class.new(filename) }

  let(:deck) { Blackjack::Deck.new }
  let(:game) { Blackjack::GameService.new(deck: deck) }
  let(:filename) { file.path }
  let(:file) { Tempfile.new('rspec.txt') }

  before(:each) { file.close }
  after(:each) { file.unlink }

  context '#all' do
    context 'When file exist' do
      before { Marshal.dump([], file.open); file.close }

      it 'returns an array of games' do
        expect(storage.all).to eq([])
      end
    end

    context 'When file doesnt exist' do
      let(:filename) { 'some_filename.txt' }

      it 'creates a file and returns an empty array' do
        expect(storage.all).to eq([])
      end
    end
  end

  context '#first' do
    let(:first_game) { game }
    let(:second_game) { Blackjack::GameService.new(deck: deck) }
    let(:games) { [ first_game, second_game ] }

    before do
      games.each(&:deal)
      Marshal.dump(games, file.open); file.close
    end

    # TODO: to_json for Hand and Deck
    # TODO: eq? for Hand and Deck
    it 'returns first game' do
      expect(storage.first.dealer_hand.cards).to eq(first_game.dealer_hand.cards)
      expect(storage.first.player_hands.map(&:cards).flatten)
        .to eq(first_game.player_hands.map(&:cards).flatten)
    end
  end

  context '#store' do
    before { game.deal }

    it 'stores games in a provided file' do
      storage.store(game)
      expect(storage.first.dealer_hand.cards).to eq(game.dealer_hand.cards)
      expect(storage.first.player_hands.map(&:cards).flatten)
        .to eq(game.player_hands.map(&:cards).flatten)
    end
  end
end
