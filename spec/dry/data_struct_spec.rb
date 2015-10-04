RSpec.describe Dry::Data::Struct do
  describe '.attribute' do
    it 'defines an attribute for the constructor' do
      module Structs
        class Address < Dry::Data::Struct
          attribute :city, "strict.string"
          attribute :zipcode, "coercible.string"
        end

        class User < Dry::Data::Struct
          attribute :name, "coercible.string"
          attribute :age, "coercible.int"
          attribute :address, "structs.address"
        end

        class SuperUser < User
          attributes(root: 'strict.bool')
        end
      end

      user_type = Dry::Data["structs.user"]
      root_type = Dry::Data["structs.super_user"]

      user = user_type[
        name: :Jane, age: '21', address: { city: 'NYC', zipcode: 123 }
      ]

      expect(user.name).to eql('Jane')
      expect(user.age).to be(21)
      expect(user.address.city).to eql('NYC')
      expect(user.address.zipcode).to eql('123')

      user = user_type[
        name: :Jane, age: '21', address: { city: 'NYC', zipcode: 123 }, invalid: 'foo'
      ]

      expect(user.name).to eql('Jane')
      expect(user.age).to be(21)
      expect(user.address.city).to eql('NYC')
      expect(user.address.zipcode).to eql('123')

      user = root_type[
        name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
      ]

      expect(user.name).to eql('Jane')
      expect(user.age).to be(21)
      expect(user.root).to be(true)
      expect(user.address.city).to eql('NYC')
      expect(user.address.zipcode).to eql('123')
    end
  end
end
