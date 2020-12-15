# frozen_string_literal: true

require "dry/types/constructor"

RSpec.describe Dry::Types::Constructor.wrapper_type do
  let(:int) { Dry::Types["coercible.integer"] }

  let(:constructor_block) do
    lambda do |input, type, &block|
      300 + type.("#{input}0", &block)
    end
  end

  let(:type) { int.constructor(constructor_block) }

  describe "#valid?" do
    specify do
      expect(type.valid?("123")).to be(true)
      expect(type.valid?("abc")).to be(false)
    end
  end

  describe "#try" do
    specify do
      expect(type.try("123")).to be_success
      expect(type.try("abc")).to be_failure
    end
  end

  describe "#lax" do
    let(:type) { super().lax }

    it "keeps underlying type not laxed since we have control over the whole construction" do
      expect(type.("abc") { :fallback }).to eql(:fallback)
    end
  end

  describe "#meta" do
    let(:type) { super().meta(foo: 1) }

    it "preserves type" do
      expect(type).to be_a(described_class)
      expect(type.valid?("123")).to be(true)
    end
  end

  describe "#call" do
    context "successful coercion" do
      specify do
        expect(type.("123")).to eql(1530)
      end

      context "constrained type" do
        let(:type) { super().constrained(gt: 300) }

        specify do
          expect(type.("123")).to eql(1530)
        end
      end
    end

    context "unsuccessful coercion with fallback" do
      specify do
        expect(type.("abc") { :fallback }).to eql(:fallback)
      end
    end
  end

  describe "builder methods" do
    describe "#prepend" do
      context "ordinary" do
        let(:type) { super().prepend { |input| "#{input}22" } }

        it "adds a prepdending constructor" do
          # 123 -> 1230 -> 123022 -> 123322
          expect(type.("123")).to eql(123_322)
        end
      end

      context "wrapping" do
        let(:type) do
          super().prepend { |input, type| type.("7#{input}") + 40 }
        end

        it "adds a prepdending constructor" do
          # 123 -> 1230 -> 71230 -> 71270 -> 71570
          expect(type.("123")).to eql(71_570)
        end
      end
    end

    describe "#append" do
      let(:type) { super().append { |input| "#{input}22" } }

      specify do
        # 123 -> 12322 -> 123220 -> 123520
        expect(type.("123")).to eql(123_520)
      end
    end

    describe "#constructor" do
      context "wrapping" do
        let(:type) { super().constructor(constructor_block) }

        it "chains wrappers" do
          expect(type.("123")).to eql(12_900)
        end
      end
    end

    describe "#constrained" do
      let(:type) { super().constrained(gt: 10_000) }

      it "raises an error on invalid input" do
        expect { type.("1") }.to raise_error(Dry::Types::ConstraintError)
      end

      it "accepts valid input" do
        expect(type.("1000")).to eql(10_300)
      end
    end
  end
end
