# frozen_string_literal: true

require "dry/types/builder"

RSpec.describe Dry::Types::Builder do
  let(:base) { Dry::Types["string"].constrained(min_size: 4) }

  describe "#fallback" do
    context "using block" do
      subject(:type) { base.fallback { "fallback" } }

      it "returns block result on invalid input" do
        expect(type.("123")).to eql("fallback")
        expect(type.("long")).to eql("long")
      end

      it "is not possible to provide a different fallback" do
        expect(type.("123") { raise }).to eql("fallback")
        expect(type.("long") { raise }).to eql("long")
      end

      context "fallback for a lax type" do
        subject(:type) { base.lax.fallback { "fallback" } }

        it "is not used" do
          expect(type.("123")).to eql("123")
        end
      end

      context "lax type after fallback" do
        subject(:type) { base.fallback { "fallback" }.lax }

        it "is used" do
          expect(type.("123")).to eql("fallback")
        end
      end

      context "complex type" do
        subject(:type) do
          Dry::Types["array"].of(
            Dry::Types["params.hash"].schema(
              name: "string",
              age: "params.integer",
              email: Dry::Types["string"].constrained(format: /@/)
            ).optional.fallback(nil)
          ).constructor { |input, type| type.(input) { [] }.compact }
        end

        let(:john_input) do
          {name: "John", age: "20", email: "john@doe.com"}
        end

        let(:john_output) do
          {name: "John", age: 20, email: "john@doe.com"}
        end

        example "working complex type" do
          expect(type.(nil)).to eql([])
          expect(type.([])).to eql([])
          expect(type.([nil])).to eql([])
          expect(type.([{}])).to eql([])
          expect(type.([john_input])).to eql([john_output])
          expect(type.([john_input, {name: "Jane", age: "22"}])).to eql([john_output])
        end
      end
    end

    context "using value" do
      subject(:type) { base.fallback("fallback") }

      it "returns block result on invalid input" do
        expect(type.("123")).to eql("fallback")
        expect(type.("long")).to eql("long")
      end

      it "is not possible to provide a different fallback" do
        expect(type.("123") { raise }).to eql("fallback")
        expect(type.("long") { raise }).to eql("long")
      end

      it "prints warning when default value isn't frozen" do
        expect(Dry::Core::Deprecations).to receive(:warn)
        base.fallback("foobar".dup)
      end

      it "doesn't print warning when default value isn't frozen with an option given" do
        expect(Dry::Core::Deprecations).not_to receive(:warn)
        base.fallback("foobar".dup, shared: true)
      end
    end

    context "providing no arguments" do
      it "raises an error" do
        expect { base.fallback }.to raise_error(
          ArgumentError, /fallback value or a block must be given/
        )
      end
    end

    context "providing invalid value" do
      it "gets rejected" do
        expect { base.fallback(123) }.to raise_error(
          Dry::Types::ConstraintError,
          /violates constraints/
        )
      end
    end
  end
end
