RSpec.describe Dry::Types::Definition do
  subject(:type) { Dry::Types::Definition.new(String) }

  it_behaves_like 'Dry::Types::Definition#meta'

  it 'is frozen' do
    expect(type).to be_frozen
  end

  describe '#constructor' do
    it 'returns a constructor' do
      coercible_string = type.constructor(&:to_s)

      expect(coercible_string[{}]).to eql({}.to_s)
    end
  end

  describe '#try' do
    let(:result) { type.try(value) }

    context 'when given valid input' do
      let(:value) { 'foo' }

      it 'returns a success' do
        expect(result).to be_success
      end

      it 'provides the original input' do
        expect(result.input).to be(value)
      end
    end

    context 'when given invalid input' do
      let(:value) { :foo }

      it 'returns a failure' do
        expect(result).to be_failure
      end

      it 'provides the original input' do
        expect(result.input).to be(value)
      end

      it "provides an error message" do
        expect(result.error).to eql(':foo must be an instance of String')
      end

      it "yields failure when given a block" do
        expect { |probe| type.try(value, &probe) }.to yield_with_args(result)
      end
    end

    describe '#===' do
      it 'return if the value pass is valid primitive' do
        expect(type.===('hello')).to eq true
      end

      context 'In case statement' do
        let(:value) do
          case 'Hello'
            when type then '0_o'
            else 2
          end
        end

        it 'use in case statement' do
          expect(value).to eq '0_o'
        end
      end
    end
  end
end
