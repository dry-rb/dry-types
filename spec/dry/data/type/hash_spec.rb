RSpec.describe Dry::Data::Type::Hash do
  describe '#schema' do
    it 'builds hash using provided schema' do
      phone = Struct.new(:prefix, :number) do
        def self.name
          'Phone'
        end
      end

      Dry::Data.register(
        "phone",
        Dry::Data::Type.new(-> args { phone.new(*args) }, phone)
      )

      hash = Dry::Data['coercible.hash'].schema(
        name: "coercible.string",
        age: "coercible.int",
        active: "strict.bool",
        phone: "phone"
      )

      user_hash = hash[
        name: :Jane, age: '21', active: true, phone: ['+48', '123-456-789']
      ]

      expect(user_hash).to eql(
        name: 'Jane', age: 21, active: true, phone: phone.new('+48', '123-456-789')
      )

      expect {
        hash[name: 'Jane', age: 21, active: 'true', phone: nil]
      }.to raise_error(
        Dry::Data::SchemaError, '"true" (String) has invalid type for :active'
      )
    end
  end
end
