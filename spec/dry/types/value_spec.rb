RSpec.describe Dry::Types::Value do
  before do
    module Test
      class Location < Dry::Types::Value
        attribute :lat, "strict.float"
        attribute :lng, "strict.float"
      end
    end
  end

  let(:loc_1) { Test::Location.new(lat: 1.234, lng: 5.678) }
  let(:loc_2) { Test::Location.new(lat: 1.234, lng: 5.678) }
  let(:loc_3) { Test::Location.new(lat: 1.234, lng: 9.876) }

  it 'defines a struct with equality methods' do
    expect(loc_1).to eql(loc_2)
    expect(loc_1).to_not eql(loc_3)
  end

  it 'defines a struct with hash based on attribute values' do
    expect(loc_1.hash).to eql(loc_2.hash)
    expect(loc_1.hash).to_not eql(loc_3.hash)
  end

  it 'defines a struct with a nice inspect' do
    expect(loc_1.inspect).to eql('#<Test::Location lat=1.234 lng=5.678>')
  end
end
