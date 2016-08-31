require 'dry/types/cache'

RSpec.describe Dry::Types::Cache do
  subject(:klass) do
    Class.new do
      extend Dry::Types::Cache
    end
  end

  describe '#fetch_or_store' do
    it 'stores and fetches a value' do
      args = [1, 2, 3]
      value = 'foo'

      expect(klass.fetch_or_store(*args) { value }).to be(value)
      expect(klass.fetch_or_store(*args)).to be(value)

      object = klass.new

      expect(object.fetch_or_store(*args) { value }).to be(value)
      expect(object.fetch_or_store(*args)).to be(value)
    end
  end
end
