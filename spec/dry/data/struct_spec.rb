RSpec.describe Dry::Data::Struct do
  context 'with defined structs' do
    let(:user_type) { Dry::Data["test.user"] }
    let(:root_type) { Dry::Data["test.super_user"] }

    before do
      module Test
        class Address < Dry::Data::Struct
          attribute :city, "strict.string"
          attribute :zipcode, "coercible.string"
        end

        class User < Dry::Data::Struct
          attribute :name, "coercible.string"
          attribute :age, "coercible.int"
          attribute :address, "test.address"
        end

        class SuperUser < User
          attributes(root: 'strict.bool')
        end
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
    end

    describe '.new' do
      it 'raises StructError when attribute constructor failed' do
        expect {
          user_type[age: {}]
        }.to raise_error(
          Dry::Data::StructError,
          "[Test::User.new] :name is missing in Hash input"
        )

        expect {
          user_type[name: :Jane, age: '21', address: nil]
        }.to raise_error(
          Dry::Data::StructError,
          "[Test::User.new] nil (NilClass) has invalid type for :address"
        )
      end
    end
  end

  describe '.[]' do
    it 'returns struct class based on attributes' do
      module Test
        class Book < Dry::Data::Struct
          attribute :published, 'bool'

          def self.[](attributes)
            if attributes[:published]
              Published
            else
              super
            end
          end
        end

        class Published < Book
        end
      end

      expect(Dry::Data['test.book'][published: false]).to be_instance_of(Test::Book)
      expect(Dry::Data['test.book'][published: true]).to be_instance_of(Test::Published)
    end
  end
end
