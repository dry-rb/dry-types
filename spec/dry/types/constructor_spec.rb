RSpec.describe Dry::Types::Constructor do
  subject(:type) do
    Dry::Types::Constructor.new(Dry::Types['string'], fn: Kernel.method(:String))
  end

  describe '.new' do
    it 'wraps primitive in a definition' do
      type = Dry::Types::Constructor.new(String, fn: Kernel.method(:String))

      expect(type.primitive).to be(String)
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
  end

  context 'decoration' do
    subject(:type) { Dry::Types['coercible.hash'] }

    it 'responds to type methods' do
      expect(type).to respond_to(:schema)
    end
  end
end
