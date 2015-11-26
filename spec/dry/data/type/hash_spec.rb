RSpec.describe Dry::Data::Type::Hash do
  subject(:hash) do
    Dry::Data['coercible.hash'].strict(
      name: "coercible.string",
      age: "coercible.int",
      active: "strict.bool",
      phone: "phone"
    )
  end

  let(:phone) do
    Dry::Data['phone'].primitive
  end

  before :all do
    phone = Struct.new(:prefix, :number) do
      def self.name
        'Phone'
      end
    end

    Dry::Data.register(
      "phone",
      Dry::Data::Type.new(-> args { phone.new(*args) }, phone)
    )
  end

  describe '#[]' do
    it 'builds hash using provided schema' do
      user_hash = hash[
        name: :Jane, age: '21', active: true, phone: ['+48', '123-456-789']
      ]

      expect(user_hash).to eql(
        name: 'Jane', age: 21, active: true, phone: phone.new('+48', '123-456-789')
      )
    end

    it 'raises SchemaError if constructing one of the values raised an error' do
      expect {
        hash[name: 'Jane', age: 21, active: 'true', phone: nil]
      }.to raise_error(
        Dry::Data::SchemaError, '"true" (String) has invalid type for :active'
      )
    end

    it 'raises SchemaKeyError if input is missing a key' do
      expect {
        hash[name: :Jane, active: true, phone: ['+48', '123-456-789']]
      }.to raise_error(
        Dry::Data::SchemaKeyError, /:age is missing in Hash input/
      )
    end
  end
end
