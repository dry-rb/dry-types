RSpec.describe Dry::Types::Constructor do
  subject(:type) do
    Dry::Types::Constructor.new(Dry::Types['string'], fn: Kernel.method(:String))
  end

  describe '.new' do
    it 'wraps primitive in a definition' do
      type = Dry::Types::Constructor.new(String, fn: Kernel.method(:String))

      expect(type.primitive).to be(String)
    end

    it 'passes builder types as its type' do
      type = Dry::Types::Constructor.new(Dry::Types['strict.string'], fn: -> v { v.strip })

      expect(type.type).to be(Dry::Types['strict.string'])
    end

    it 'allows block as the fn' do
      type = Dry::Types::Constructor.new(String, &:strip)

      expect(type[' foo ']).to eql('foo')
    end
  end

  describe '#call' do
    it 'uses constructor function to process input' do
      expect(type[:foo]).to eql('foo')
    end
  end

  describe '#primitive' do
    it 'delegates to its definition' do
      expect(type.primitive).to be(String)
    end
  end

  describe '#constructor' do
    it 'returns a new constructor' do
      upcaser = type.constructor(-> s { s.upcase }, id: :upcaser)

      expect(upcaser[:foo]).to eql('FOO')
      expect(upcaser.options[:id]).to be(:upcaser)
    end

    it 'accepts a block' do
      upcaser = type.constructor(id: :upcaser, &:upcase)

      expect(upcaser[:foo]).to eql('FOO')
      expect(upcaser.options[:id]).to be(:upcaser)
    end
  end

  context 'decoration' do
    subject(:type) { Dry::Types['coercible.hash'] }

    it 'responds to type methods' do
      expect(type).to respond_to(:schema)
    end

    it 'returns response when it is not a type definition' do
      expect(type.constrained(type: Hash).rule).to be_kind_of(Dry::Logic::Rule)
    end

    it 'raises no-method error when it does not respond to a method' do
      expect { type.oh_noez }.to raise_error(NoMethodError)
    end
  end

  describe 'equality' do
    it_behaves_like 'a type with equality defined' do
      let(:type) { Dry::Types::Constructor.new(String, &:strip) }
    end
  end
end
