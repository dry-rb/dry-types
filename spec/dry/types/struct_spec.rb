RSpec.describe Dry::Types::Struct do
  let(:user_type) { Dry::Types["test.user"] }
  let(:root_type) { Dry::Types["test.super_user"] }

  before do
    module Test
      class Address < Dry::Types::Struct
        attribute :city, "strict.string"
        attribute :zipcode, "coercible.string"
      end

      class User < Dry::Types::Struct
        attribute :name, "coercible.string"
        attribute :age, "coercible.int"
        attribute :address, "test.address"
      end

      class SuperUser < User
        attributes(root: 'strict.bool')
      end
    end
  end

  describe '.new' do
    it 'raises StructError when attribute constructor failed' do
      expect {
        user_type[age: {}]
      }.to raise_error(
        Dry::Types::StructError,
        "[Test::User.new] :name is missing in Hash input"
      )

      expect {
        user_type[name: :Jane, age: '21', address: nil]
      }.to raise_error(
        Dry::Types::StructError,
        "[Test::User.new] nil (NilClass) has invalid type for :address"
      )
    end

    it 'passes through values when they are structs already' do
      address = Test::Address.new(city: 'NYC', zipcode: '312')
      user = user_type[name: 'Jane', age: 21, address: address]

      expect(user.address).to be(address)
    end
  end

  describe '.attribute' do
    def assert_valid_struct(user)
      expect(user.name).to eql('Jane')
      expect(user.age).to be(21)
      expect(user.address.city).to eql('NYC')
      expect(user.address.zipcode).to eql('123')
    end

    it 'defines attributes for the constructor' do
      user = user_type[
        name: :Jane, age: '21', address: { city: 'NYC', zipcode: 123 }
      ]

      assert_valid_struct(user)
    end

    it 'ignores unknown keys' do
      user = user_type[
        name: :Jane, age: '21', address: { city: 'NYC', zipcode: 123 }, invalid: 'foo'
      ]

      assert_valid_struct(user)
    end

    it 'merges attributes from the parent struct' do
      user = root_type[
        name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
      ]

      assert_valid_struct(user)

      expect(user.root).to be(true)
    end

    it 'raises error when type is missing' do
      expect {
        class Test::Foo < Dry::Types::Struct
          attribute :bar
        end
      }.to raise_error(ArgumentError)
    end
  end

  describe 'with a safe schema' do
    it 'uses :safe constructor when constructor_type is overridden' do
      struct = Class.new(Dry::Types::Struct) do
        constructor_type(:schema)

        attribute :name, Dry::Types['strict.string'].default('Jane')
        attribute :admin, Dry::Types['strict.bool'].default(true)
      end

      expect(struct.new(name: 'Jane').to_h).to eql(name: 'Jane', admin: true)
      expect(struct.new.to_h).to eql(name: 'Jane', admin: true)
    end
  end

  describe '#eql' do
    context 'when struct values are equal' do
      let(:user_1) do
        root_type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end
      let(:user_2) do
        root_type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end
      it 'returns true' do
        expect(user_1).to eql(user_2)
      end
    end

    context 'when struct values are not equal' do
      let(:user_1) do
        root_type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end
      let(:user_2) do
        root_type[
          name: :Mike, age: '43', root: false, address: { city: 'Atlantis', zipcode: 456 }
        ]
      end
      it 'returns false' do
        expect(user_1).to_not eql(user_2)
      end
    end
  end

  describe '#hash' do
    context 'when struct values are equal' do
      let(:user_1) do
        root_type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end
      let(:user_2) do
        root_type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end
      it 'the hashes are equal' do
        expect(user_1.hash).to eql(user_2.hash)
      end
    end

    context 'when struct values are not equal' do
      let(:user_1) do
        root_type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end
      let(:user_2) do
        root_type[
          name: :Mike, age: '43', root: false, address: { city: 'Atlantis', zipcode: 456 }
        ]
      end
      it 'the hashes are not equal' do
        expect(user_1.hash).to_not eql(user_2.hash)
      end
    end
  end

  describe '#to_h' do
    it 'returns hash with attributes' do
      attributes = {
        name: 'Jane', age: 21, address: { city: 'NYC', zipcode: '123' }
      }

      expect(user_type[attributes].to_h).to eql(attributes)
    end
  end
end
