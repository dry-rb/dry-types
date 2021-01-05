# frozen_string_literal: true

RSpec.describe Dry::Types::Result do
  before { Dry::Types.load_extensions(:monads) }

  let(:type) { Dry::Types["strict.string"] }

  let(:result) { type.try(input) }

  context "interface" do
    let(:input) { {} }

    it "responds to #to_monad" do
      expect(result).to respond_to(:to_monad)
    end
  end

  context "with valid input" do
    let(:input) { "Jane" }

    describe "#to_monad" do
      it "wraps Result with Success" do
        monad = result.to_monad

        expect(monad).to be_a Dry::Monads::Result
        expect(monad).to be_success
        expect(monad.value!).to eq(result.input)
      end
    end
  end

  context "with invalid input" do
    let(:input) { nil }

    describe "#to_monad" do
      it "wraps Result with Failure" do
        monad = result.to_monad

        expect(monad).to be_a Dry::Monads::Result
        expect(monad).to be_failure
        expect(monad.failure).to eq([result.error, result.input])
      end
    end
  end
end
