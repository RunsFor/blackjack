require 'spec_helper'

describe Blackjack::Play do
  subject(:play) { described_class.new }

  context '.new' do
    it 'contains dealers and players initial hands' do
      expect(play).to respond_to(:dealer_hand)
      expect(play).to respond_to(:player_hand)
      expect(play).to respond_to(:player_hands)
      expect(play.dealer_hand.cards).to_not be_empty
      expect(play.player_hand.cards).to_not be_empty
    end
  end
end
