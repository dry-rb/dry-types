RSpec.describe Dry::Types::Definition do
  subject(:type) { Dry::Types::Definition.new(String) }

  describe '#meta' do
    it 'allows setting meta information' do
      with_meta = type.meta(foo: :bar)

      expect(with_meta).to be_instance_of(type.class)
      expect(with_meta.meta).to eql(foo: :bar)
    end
  end
end
