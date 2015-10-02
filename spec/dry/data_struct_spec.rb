RSpec.describe Dry::Data::Struct do
  describe '.attribute' do
    it 'defines an attribute for the constructor' do
      class Address
        include Dry::Data::Struct

        attributes city: "strict.string", zipcode: "coercible.string"
      end

      class User
        include Dry::Data::Struct

        attributes(
          name: "coercible.string",
          age: "coercible.int",
          active: "strict.bool",
          address: "address"
        )
      end

      user_type = Dry::Data["user"]

      user = user_type[name: :Jane, age: '21', address: { city: 'NYC', zipcode: 123 }]

      expect(user.name).to eql('Jane')
      expect(user.age).to be(21)
      expect(user.address.city).to eql('NYC')
      expect(user.address.zipcode).to eql('123')
    end
  end
end
