RSpec.describe Dry::Data::Struct do
  describe '.attribute' do
    it 'defines an attribute for the constructor' do
      class Address
        include Dry::Data::Struct

        attributes city: String, zipcode: String
      end

      class User
        include Dry::Data::Struct

        attributes name: String, age: Integer, active: Bool, address: Address
      end

      user_type = Dry::Data.new { |t| t['User'] }

      user = user_type[name: :Jane, age: '21', address: { city: 'NYC', zipcode: 123 }]

      expect(user.name).to eql('Jane')
      expect(user.age).to be(21)
      expect(user.address.city).to eql('NYC')
      expect(user.address.zipcode).to eql('123')
    end
  end
end
