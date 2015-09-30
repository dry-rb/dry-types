RSpec.describe Dry::Data::TypedHash do
  describe '.new' do
    it 'builds hash using provided schema' do
      address = Struct.new(:street, :city) do
        def self.name
          'Address'
        end
      end

      Dry::Data.register(address, -> args { address.new(*args) })

      hash = Dry::Data::TypedHash.new(
        name: 'String',
        age: 'Integer',
        active: 'Bool',
        address: 'Address'
      )

      user_hash = hash[
        name: :Jane, age: '21', active: true, address: ['Street 12', 'NYC']
      ]

      expect(user_hash).to eql(
        name: 'Jane', age: 21, active: true, address: address.new('Street 12', 'NYC')
      )

      expect { hash[name: 'Jane', age: 21, active: 'true', address: nil] }
        .to raise_error(TypeError, /"true" has invalid type/)
    end
  end
end
