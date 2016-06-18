RSpec.describe Dry::Types::Value do
  before do
    module Test
      class Address < Dry::Types::Value
        attribute :city, "strict.string"
        attribute :zipcode, "coercible.string"
      end

      class User < Dry::Types::Value
        attribute :name, "coercible.string"
        attribute :age, "coercible.int"
        attribute :address, "test.address"
      end

      class SuperUser < User
        attributes(root: 'strict.bool')
      end
    end
  end

  it_behaves_like Dry::Types::Struct do
    subject(:type) { Dry::Types['test.super_user'] }
  end

  it 'is deeply frozen' do
    address = Test::Address.new(city: 'NYC', zipcode: 123)
    expect(address).to be_frozen
    expect(address.city).to be_frozen
  end

  context 'when deep freezing' do
    before do
      module Test
        class Name
          def initialize(full)
            @full = full
          end

          attr_reader :full
        end

        Dry::Types.register_class(Name)

        class Person < Dry::Types::Value
          attribute :name, Name
        end
      end
    end

    it 'deep freezes plain member objects' do
      person = Test::Person.new(name: Test::Name.new('John Doe'))

      expect(person).to be_frozen
      expect(person.name).to be_frozen
      expect(person.name.full).to be_frozen
    end
  end
end
