RSpec.describe Dry::Types::Definition::Hash do
  subject(:hash) do
    Dry::Types['coercible.hash'].strict(
      name: "coercible.string",
      age: "coercible.int",
      active: "strict.bool",
      phone: Dry::Types['phone'],
      loc: Test::Location
    )
  end

  let(:phone) do
    Dry::Types['phone'].primitive
  end

  before do
    phone = Struct.new(:prefix, :number) do
      def self.name
        'Phone'
      end
    end

    module Test
      class Location < Dry::Types::Value
        attributes(lat: 'float', lng: 'float')
      end
    end

    Dry::Types.register(
      "phone",
      Dry::Types::Definition.new(phone).constructor(-> args { phone.new(*args) })
    )
  end

  describe '#[]' do
    it 'builds hash using provided schema' do
      user_hash = hash[
        name: :Jane, age: '21', active: true,
        phone: ['+48', '123-456-789'],
        loc: { lat: 1.23, lng: 4.56 }
      ]

      expect(user_hash).to eql(
        name: 'Jane', age: 21, active: true,
        phone: phone.new('+48', '123-456-789'),
        loc: Test::Location.new(lat: 1.23, lng: 4.56)
      )
    end

    it 'raises SchemaError if constructing one of the values raised an error' do
      expect {
        hash[name: 'Jane', age: 21, active: 'true', phone: nil]
      }.to raise_error(
        Dry::Types::SchemaError, '"true" (String) has invalid type for :active'
      )
    end

    it 'raises SchemaKeyError if input is missing a key' do
      expect {
        hash[name: :Jane, active: true, phone: ['+48', '123-456-789']]
      }.to raise_error(
        Dry::Types::SchemaKeyError, /:age is missing in Hash input/
      )
    end
  end
end
