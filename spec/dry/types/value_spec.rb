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

  it 'is frozen' do
    expect(Test::Address.new(city: 'NYC', zipcode: 123)).to be_frozen
  end
end
