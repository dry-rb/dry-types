RSpec.describe Dry::Types::Array do
  describe '#member' do
    context 'primitive' do
      shared_context 'array with a member type' do
        it 'returns an array with correct member values' do
          expect(array[Set[1, 2, 3]]).to eql(%w(1 2 3))
        end
      end

      context 'using string identifiers' do
        subject(:array) { Dry::Types['coercible.array<coercible.string>'] }

        include_context 'array with a member type'
      end

      context 'using method' do
        subject(:array) { Dry::Types['coercible.array'].member(Dry::Types['coercible.string']) }

        include_context 'array with a member type'
      end

      context 'using a constrained type' do
        subject(:array) do
          Dry::Types['array'].member(Dry::Types['coercible.int'].constrained(gt: 2))
        end

        it 'passes values through member type' do
          expect(array[%w(3 4 5)]).to eql([3, 4, 5])
        end

        it 'raises when input is not valid' do
          expect { array[%w(1 2 3)] }.to raise_error(
            Dry::Types::ConstraintError,
            '1 violates constraints (gt?(2) failed)'
          )
        end
      end
    end

    context 'struct' do
      it 'uses struct constructor for member values' do
        module Test
          class User < Dry::Types::Struct
            attribute :name, 'string'
          end
        end

        array = Dry::Types['array'].member(Test::User)

        jane, john = array[[{ name: 'Jane' }, { name: 'John' }]]

        expect(jane).to be_instance_of(Test::User)
        expect(john).to be_instance_of(Test::User)

        expect(jane.name).to eql('Jane')
        expect(john.name).to eql('John')
      end
    end

    context 'enum' do
      it 'uses enum type for member values' do
        enum = Dry::Types['strict.string'].enum(*%w(draft published archived))
        array = Dry::Types['array'].member(enum)

        expect{ array[['draft', 'published']] }.to_not raise_error
        expect{ array[['trash', 'published']] }.to raise_error(Dry::Types::ConstraintError)
      end
      it 'uses enum type for member values if Object was monkeypatched' do
        Object.send(:define_method, :try){|*| nil}

        enum = Dry::Types['strict.string'].enum(*%w(draft published archived))
        array = Dry::Types['strict.array'].member(enum)

        expect{ array[['draft', 'published']] }.to_not raise_error
        Object.send(:remove_method, :try)
      end
    end
  end
end
