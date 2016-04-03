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
    subject(:try) { type.try(value) }

    let(:success) { try.success?    }
    let(:failure) { try.failure?    }
    let(:input)   { try.input       }

    context 'when given valid input' do
      let(:value) { 'foo' }

      specify { expect(success).to be(true)  }
      specify { expect(failure).to be(false) }
      specify { expect(input).to be(value)   }
    end

    context 'when given invalid input' do
      let(:value) { :foo }

      specify { expect(success).to be(false) }
      specify { expect(failure).to be(true)  }
      specify { expect(input).to be(value)   }

      it "provides an error message" do
        expect(try.error).to eql(':foo must be an instance of String')
      end

      it "yields failure when given a block" do
        expect { |probe| type.try(value, &probe) }.to yield_with_args(try)
      end
    end
  end
end
