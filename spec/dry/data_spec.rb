RSpec.describe Dry::Data do
  describe '.register' do
    it 'registers a new type constructor' do
      class CustomArray
        def self.new(input)
          Array(input)
        end
      end

      Dry::Data.register(:CustomArray, CustomArray.method(:new), primitive: CustomArray)

      type = Dry::Data[:CustomArray]

      expect(type['foo']).to eql(['foo'])
    end
  end

  describe '.[]' do
    context 'when the type exists' do
      it 'returns registered type' do
        expect(Dry::Data[:string]).to be_a(Dry::Data::Type)
      end
    end

    context 'when the type does not exist' do
      it 'errors' do
        expect { Dry::Data[:custom] }.to raise_error(Dry::Data::Error)
      end
    end
  end
end
