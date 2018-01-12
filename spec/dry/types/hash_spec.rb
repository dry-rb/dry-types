RSpec.describe Dry::Types::Hash do
  let(:type) { Dry::Types['hash'] }

  it_behaves_like Dry::Types::Definition
  it_behaves_like 'Dry::Types::Definition#meta'

  describe '#call' do
    it 'accepts any hash input' do
      expect(type.({})).to eql({})
      expect(type.(name: 'Jade')).to eql(name: 'Jade')
    end
  end

  describe 'hash schema' do
    let(:hash_schema) do
      {
        name: "coercible.string",
        age: "strict.integer",
        active: "form.bool",
        phone: Dry::Types['phone']
      }
    end

    let(:primitive) do
      type.meta(my: :metadata)
    end

    let(:hash) { primitive.schema(hash_schema) }

    let(:phone) { Dry::Types['phone'].primitive }

    before do
      phone = Struct.new(:prefix, :number) do
        def self.name
          'Phone'
        end
      end

      Dry::Types.register(
        "phone",
        Dry::Types::Definition.new(phone).constructor(-> args { phone.new(*args) })
      )
    end

    it_behaves_like Dry::Types::Definition do
      let(:type) { Dry::Types['hash'].schema(hash_schema) }
    end

    it_behaves_like 'Dry::Types::Definition#meta' do
      let(:type) { Dry::Types['hash'].schema(hash_schema) }
    end

    context 'members with default values' do
      let(:hash) {
        primitive.schema(
          **hash_schema,
          age: Dry::Types["strict.integer"].default(21)
        )
      }

      it 'resolves missing keys with default values' do
        params = { name: 'Jane', active: true, phone: [] }
        expect(hash[params][:age]).to eql(21)
      end
    end

    it 'preserves metadata' do
      expect(hash.meta[:my]).to eql(:metadata)
    end

    it 'has a Hash primitive' do
      expect(hash.primitive).to be(::Hash)
    end

    it 'is callable via #[]' do
      params = { name: :Jane, age: 21, active: true, phone: [] }
      expect(hash[params]).to eql(hash.call(params))
    end

    it 'builds hash using provided schema' do
      user_hash = hash.call(
        name: :Jane, age: 21, active: true,
        phone: ['+48', '123-456-789']
      )

      expect(user_hash).
        to eql(
             name: 'Jane', age: 21, active: true,
             phone: phone.new('+48', '123-456-789')
           )
    end

    it 'applies member types' do
      input = { name: :John, age: 21, active: 'true', phone: %w[1 234] }
      result = hash.try(input)

      expect(result).to be_success
      expect(result.input).to eql(name: 'John', age: 21, active: true, phone: phone.new('1', '234'))
    end

    it 'keeps original values when applying a member type fails' do
      input = { age: 'twenty one', active: '0', name: 'John', phone: %w[1 234] }
      result = hash.try(input)

      expect(result).to be_failure
      expect(result.input).to eql(age: 'twenty one', active: false, name: 'John', phone: phone.new('1', '234'))
    end

    it 'yields failure on #try when applying a member type fails' do
      input = { age: 'twenty one', active: '0', name: 'John', phone: %w[1 234] }

      # assert that a failed #try yields a failure result
      expect { |rspec_probe| hash.try(input, &rspec_probe) }
        .to yield_with_args(instance_of(Dry::Types::Result::Failure))

      # assert that the failure result provides context for the failing input
      hash.try(input) do |failure|
        expect(failure.error[:age].success?).to be(false)
      end
    end

    describe '#valid?' do
      it 'returns boolean' do
        expect(hash.valid?(name: 'John', age: 23, active: 1, phone: 1)).to eql(true)
        expect(hash.valid?(name: 'John', age: '23', active: 1, phone: 1)).to eql(false)
      end
    end

    describe '#===' do
      it 'returns boolean' do
        expect(hash.===(name: 'John', age: 23, active: 1, phone: 1)).to eql(true)
        expect(hash.===(name: 'John', age: '23', active: 1, phone: 1)).to eql(false)
      end
    end

    it 'raises MissingKeyError if input is missing a key' do
      expect {
        hash.call(name: :Jane, active: true, phone: ['+48', '123-456-789'])
      }.to raise_error(
             Dry::Types::MissingKeyError, /:age is missing in Hash input/
           )
    end

    it 'fails if any coercions are unsuccessful' do
      expect { hash.call(name: :Jane, age: 'oops', active: true, phone: []) }
        .to raise_error(
              Dry::Types::SchemaError,
              '"oops" (String) has invalid type for :age violates '\
              'constraints (type?(Integer, "oops") failed)'
            )
    end

    it 'rejects unexpected keys' do
      expected_input = { name: :Jane, age: 21, active: true, phone: ['1', '2'] }
      unexpected_input = { gender: 'F', email: 'Jane@hotmail.biz' }

      expect { hash.call(expected_input.merge(unexpected_input)) }
        .to raise_error(Dry::Types::UnknownKeysError)
              .with_message('unexpected keys [:gender, :email] in Hash input')
    end
  end
end
