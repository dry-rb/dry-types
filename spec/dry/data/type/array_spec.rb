RSpec.describe Dry::Data::Type::Array do
  describe '#member' do
    context 'primitive' do
      shared_context 'array with a member type' do
        it 'returns an array with correct member values' do
          expect(array[Set[1, 2, 3]]).to eql(%w(1 2 3))
        end
      end

      context 'using string identifiers' do
        subject(:array) { Dry::Data['coercible.array<coercible.string>'] }

        include_context 'array with a member type'
      end

      context 'using method' do
        subject(:array) { Dry::Data['coercible.array'].member(Dry::Data['coercible.string']) }

        include_context 'array with a member type'
      end
    end

    context 'struct' do
      it 'uses struct constructor for member values' do
        module Test
          class User < Dry::Data::Struct
            attribute :name, 'string'
          end
        end

        array = Dry::Data['array'].member(Test::User)

        jane, john = array[[{ name: 'Jane' }, { name: 'John' }]]

        expect(jane).to be_instance_of(Test::User)
        expect(john).to be_instance_of(Test::User)

        expect(jane.name).to eql('Jane')
        expect(john.name).to eql('John')
      end
    end
  end
end
