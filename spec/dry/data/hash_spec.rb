RSpec.describe Dry::Data::Hash do
  describe '.new' do
    context 'with default container' do
      it 'creates a typed hash with the Dry::Data container' do
        schema = Dry::Data::Hash.new(id: :int, name: :string, age: :int)

        expect(schema[id: '1', name: :John, age: '21']).to eql(
          id: 1,
          name: 'John',
          age: 21
        )
      end
    end

    context 'with custom container' do
      it 'creates a typed hash with the given container' do
        container = Dry::Data::Container.new
        container.register(:string, Kernel.method(:String), primitive: String)
        container.register(:int, Kernel.method(:Integer), primitive: Integer, coercible_from: String)
        container.register(:bool, ->(input) { input.to_s == 'true' })

        schema = Dry::Data::Hash.new({ id: :int, name: :string, active: :bool }, container)

        expect(schema[id: '1', name: :John, active: 'true']).to eql(
          id: 1,
          name: 'John',
          active: true
        )
      end
    end
  end
end
