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
    it_behaves_like Dry::Types::Definition do
      let(:type) { hash }
    end

    it_behaves_like 'Dry::Types::Definition#meta' do
      let(:type) { hash }
    end

    it 'builds hash using provided schema' do
      user_hash = hash[
        name: :Jane, age: 21, active: true,
        phone: ['+48', '123-456-789']
      ]

      expect(user_hash).to eql(
        name: 'Jane', age: 21, active: true,
        phone: phone.new('+48', '123-456-789')
      )
    end
  end

  shared_examples 'strict schema behavior for missing keys' do
    it 'raises MissingKeyError if input is missing a key' do
      expect {
        hash[name: :Jane, active: true, phone: ['+48', '123-456-789']]
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

  describe '#schema' do
    let(:hash) { Dry::Types['hash'].schema(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'weak schema behavior for missing keys'
  end

  describe '#weak' do
    let(:hash) { Dry::Types['hash'].weak(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'weak schema behavior for missing keys'
  end

  describe '#symbolized' do
    let(:hash) { Dry::Types['hash'].symbolized(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'weak schema behavior for missing keys'
  end

  describe '#permissive' do
    let(:hash) { Dry::Types['hash'].permissive(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'strict schema behavior for missing keys'
  end

  describe '#strict' do
    let(:hash) { Dry::Types['hash'].strict(hash_schema) }

    include_examples 'hash schema behavior'
    include_examples 'strict schema behavior for missing keys'
  end

  describe '#weak' do
    let(:hash) { Dry::Types['hash'].weak(hash_schema) }

    it 'returns a weakly-typed hash' do
      expect(hash[age: 'oops']).to eql(age: 'oops')
    end
  end

  describe '#try' do
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
  end

  describe '#[]' do
    subject(:hash) do
      Dry::Types['hash'].permissive(hash_schema)
    end

    it 'raises SchemaError if constructing one of the values raised an error' do
      expect {
        hash[name: 'Jane', age: '21', active: true, phone: nil]
      }.to raise_error(
        Dry::Types::SchemaError, '"21" (String) has invalid type for :age'
      )
    end
  end
end
