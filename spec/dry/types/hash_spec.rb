RSpec.describe Dry::Types::Hash do
  subject(:hash) do
    Dry::Types['hash'].schema(date: 'form.date', bool: 'form.bool')
  end

  describe '#weak' do
    it 'returns a weakly-typed hash' do
      hash = Dry::Types['hash'].weak(date: 'form.date')

      expect(hash[date: 'oops']).to eql(date: 'oops')
    end
  end

  describe '#try' do
    it 'applies member types' do
      input = { date: '2011-10-09', bool: '1' }
      result = hash.try(input)

      expect(result).to be_success
      expect(result.input).to eql(date: Date.new(2011, 10, 9), bool: true)
    end

    it 'keeps original values when applying a member type fails' do
      input = { date: 'not-a-date', bool: '0' }
      result = hash.try(input)

      expect(result).to be_failure
      expect(result.input).to eql(date: 'not-a-date', bool: false)
    end
  end

  describe '#[]' do
    subject(:hash) do
      Dry::Types['coercible.hash'].strict(
        name: "coercible.string",
        age: "coercible.int",
        active: "strict.bool",
        phone: Dry::Types['phone']
      )
    end

    let(:phone) do
      Dry::Types['phone'].primitive
    end

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

    it 'builds hash using provided schema' do
      user_hash = hash[
        name: :Jane, age: '21', active: true,
        phone: ['+48', '123-456-789']
      ]

      expect(user_hash).to eql(
        name: 'Jane', age: 21, active: true,
        phone: phone.new('+48', '123-456-789')
      )
    end

    it 'raises SchemaError if constructing one of the values raised an error' do
      expect {
        hash[name: 'Jane', age: 21, active: 'true', phone: nil]
      }.to raise_error(
        Dry::Types::SchemaError, '"true" (String) has invalid type for :active'
      )
    end

    it 'raises SchemaKeyError if input is missing a key' do
      expect {
        hash[name: :Jane, active: true, phone: ['+48', '123-456-789']]
      }.to raise_error(
        Dry::Types::SchemaKeyError, /:age is missing in Hash input/
      )
    end
  end
end
