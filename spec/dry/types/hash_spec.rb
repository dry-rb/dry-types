RSpec.describe Dry::Types::Hash do
  subject(:hash) do
    Dry::Types['hash'].schema(hash_schema)
  end

  let(:hash_schema) do
    {
      name: "coercible.string",
      age: "strict.int",
      active: "form.bool",
      phone: Dry::Types['phone']
    }
  end

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

  shared_examples 'hash schema behavior' do
    let(:type) { Dry::Types['hash'] }

    let(:primitive) do
      type.meta(my: :metadata)
    end

    it_behaves_like Dry::Types::Definition
    it_behaves_like 'Dry::Types::Definition#meta'

    it 'preserves metadata' do
      expect(hash.meta).to eql(my: :metadata)
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

      expect(user_hash).to eql(
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
  end

  shared_examples 'strict schema behavior for missing keys' do
    it 'raises MissingKeyError if input is missing a key' do
      expect {
        hash.call(name: :Jane, active: true, phone: ['+48', '123-456-789'])
      }.to raise_error(
        Dry::Types::MissingKeyError, /:age is missing in Hash input/
      )
    end
  end

  shared_examples 'weak schema behavior for missing keys' do
    it 'allows omitting keys' do
      expect(hash[{}]).to eql({})
    end
  end

  shared_examples 'weak typing behavior' do
    it 'preserves successful coercions and ignores failed coercions' do
      expect(hash.call(name: :Jane, age: 'oops', active: true, phone: []))
        .to eql(name: 'Jane', age: 'oops', active: true, phone: phone.new)
    end
  end

  shared_examples 'strict typing behavior' do
    it 'fails if any coercions are unsuccessful' do
      expect { hash.call(name: :Jane, age: 'oops', active: true, phone: []) }
        .to raise_error(Dry::Types::SchemaError, '"oops" (String) has invalid type for :age violates constraints (type?(Integer, "oops") failed)')
    end
  end

  shared_examples 'sets default value behavior when keys are omitted' do
    context 'when default value for :age is 21' do
      let(:hash_schema) do
        {
          name: "coercible.string",
          age: Dry::Types["strict.int"].default(21),
          active: "form.bool",
          phone: Dry::Types['phone']
        }
      end

      it 'fills in default value when key is omitted' do
        user = hash.call(name: :John, active: '1', phone: [])
        expect(user[:age]).to be(21)
      end
    end
  end

  shared_examples 'strict schema behavior for unexpected keys' do
    it 'rejects unexpected keys' do
      expected_input = { name: :Jane, age: 21, active: true, phone: ['1', '2'] }
      unexpected_input = { gender: 'F', email: 'Jane@hotmail.biz' }

      expect { hash.call(expected_input.merge(unexpected_input)) }
        .to raise_error(Dry::Types::UnknownKeysError)
        .with_message('unexpected keys [:gender, :email] in Hash input')
    end
  end

  shared_examples 'permissive schema behavior for nil values on fields with defaults' do
    context 'when default value for :age is 21' do
      let(:hash_schema) do
        {
          name: "coercible.string",
          age: Dry::Types["strict.int"].default(21),
          active: "form.bool",
          phone: Dry::Types['phone']
        }
      end

      it 'fills in default value when value is nil' do
        user = hash.call(name: :John, active: '1', age: nil, phone: [])
        expect(user[:age]).to be(21)
      end
    end
  end

  shared_examples 'strict schema behavior for nil values on fields with defaults' do
    context 'when default value for :age is 21' do
      let(:hash_schema) do
        {
          name: "coercible.string",
          age: Dry::Types["strict.int"].default(21),
          active: "form.bool",
          phone: Dry::Types['phone']
        }
      end

      it 'fills in default value when value is nil' do
        expect { hash.call(name: :John, active: '1', age: nil, phone: []) }
          .to raise_error(Dry::Types::SchemaError, 'nil (NilClass) has invalid type for :age violates constraints (type?(Integer, nil) failed)')
      end
    end
  end

  describe '#schema' do
    let(:hash) { primitive.schema(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'weak schema behavior for missing keys'
    include_examples 'sets default value behavior when keys are omitted'
    include_examples 'permissive schema behavior for nil values on fields with defaults'
    include_examples 'strict typing behavior'
  end

  describe '#weak' do
    let(:hash) { primitive.weak(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'weak schema behavior for missing keys'
    include_examples 'weak typing behavior'
    include_examples 'permissive schema behavior for nil values on fields with defaults'
    include_examples 'sets default value behavior when keys are omitted'

    it 'yields a special failure if #try is given a non-hash' do
      invalid_input = double(:not_a_hash)

      expect { |rspec_probe| hash.try(invalid_input, &rspec_probe) }
        .to yield_with_args(instance_of(Dry::Types::Result::Failure))

      hash.try(invalid_input) do |failure|
        expect(failure.error).to eql('#[Double :not_a_hash] must be a hash')
      end
    end
  end

  describe '#symbolized' do
    let(:hash) { primitive.symbolized(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'weak schema behavior for missing keys'
    include_examples 'weak typing behavior'
    include_examples 'permissive schema behavior for nil values on fields with defaults'
    include_examples 'sets default value behavior when keys are omitted'
  end

  describe '#permissive' do
    let(:hash) { primitive.permissive(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'strict schema behavior for missing keys'
    include_examples 'strict typing behavior'
    include_examples 'permissive schema behavior for nil values on fields with defaults'
  end

  describe '#strict' do
    let(:hash) { primitive.strict(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'strict schema behavior for missing keys'
    include_examples 'strict typing behavior'
    include_examples 'strict schema behavior for unexpected keys'
    include_examples 'strict schema behavior for nil values on fields with defaults'

    context 'with a sum' do
      let(:hash) { h1 | h2 }

      let(:h1) { Dry::Types['strict.hash'].strict(name: Dry::Types['strict.string']) }
      let(:h2) { Dry::Types['strict.hash'].strict(age: Dry::Types['strict.int']) }

      it 'returns input when it is valid for the left side' do
        expect(hash[name: 'Jane']).to eql(name: 'Jane')
      end

      it 'returns input when it is valid for the right side' do
        expect(hash[age: 21]).to eql(age: 21)
      end

      it 'raises error when it is invalid for both sides' do
        expect { hash[oops: 'boom!'] }.to raise_error(Dry::Types::ConstraintError, /oops/)
      end
    end
  end

  describe '#strict_with_defaults' do
    let(:hash) { primitive.strict_with_defaults(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'strict schema behavior for missing keys'
    include_examples 'strict typing behavior'
    include_examples 'strict schema behavior for unexpected keys'
    include_examples 'sets default value behavior when keys are omitted'
    include_examples 'strict schema behavior for nil values on fields with defaults'
  end
end
