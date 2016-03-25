RSpec.describe Dry::Types::Value do
  before do
    module Test
      class Location < Dry::Types::Value
        attribute :lat, "strict.float"
        attribute :lng, "strict.float"
      end
    end
  end

  describe '.new' do
    let(:loc) { Test::Location.new(lat: 1.234, lng: 5.678) }

    it 'returns a frozen instance' do
      expect(loc).to be_frozen
    end
  end
end
