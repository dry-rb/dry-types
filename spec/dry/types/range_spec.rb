# frozen_string_literal: true

RSpec.describe Dry::Types::Range do
  describe "#of" do
    context "primitive" do
      shared_context "range with a member type" do
        it_behaves_like Dry::Types::Nominal do
          subject(:type) { range }
        end
      end

      context "using string identifiers" do
        subject(:range) { Dry::Types["nominal.range<coercible.string>"] }

        include_context "range with a member type"
      end

      context "using method" do
        subject(:range) { Dry::Types["nominal.range"].of(Dry::Types["coercible.integer"]) }

        include_context "range with a member type"
      end

      context "coercing dates" do
        subject(:range) { Dry::Types["nominal.range"].of(Dry::Types["params.date"]) }

        it "coerces members to dates" do
          start_on = Date.new(2022, 9, 6)
          end_on = Date.new(2022, 9, 7)
          expect(range[start_on.to_s..end_on.to_s]).to eql(start_on..end_on)
        end
      end

      context "try" do
        subject(:range) { Dry::Types["nominal.range"].of(Dry::Types["strict.integer"]) }

        it "with a valid range" do
          expect(range.try(1..2)).to eq Dry::Types::Result::Success.new(1..2)
        end

        it "with a valid range" do
          expect(range.try(1..2)).to be_success
        end

        it "an invalid type should be a failure" do
          expect(range.try("some string")).to be_failure
        end

        it "a broken constraint should be a failure" do
          expect(range.try(1..2.0)).to be_failure
        end

        it "a broken constraint with block" do
          expect(
            range.try(1..2.0) { |error| "error: #{error}" }
          ).to match("error: 2.0 violates constraints (type?(Integer, 2.0) failed)")
        end

        it "an invalid type with a block" do
          expect(
            range.try("X") { |x| "error: #{x}" }
          ).to eql("error: X is not a range")
        end
      end

      context "using a constrained type" do
        subject(:range) do
          Dry::Types["range"].of(Dry::Types["coercible.integer"].constrained(gt: 2))
        end

        it "passes values through member type" do
          expect(range[3..5]).to eql(3..5)
        end

        it "raises when input is not valid" do
          expect { range["1".."3"] }.to raise_error(
            Dry::Types::ConstraintError,
            '"1" violates constraints (gt?(2, 1) failed)'
          )
        end

        it_behaves_like Dry::Types::Nominal do
          subject(:type) { range }

          it_behaves_like "a composable constructor"
        end
      end

      context "undefined" do
        subject(:range) do
          Dry::Types["range"].of(
            Dry::Types["nominal.integer"].constructor { |value|
              value == 2 ? Dry::Types::Undefined : value
            }
          )
        end

        it "filters out undefined values" do
          expect(range[1..2]).to eql(1..)
        end
      end
    end
  end

  describe "#valid?" do
    subject(:range) { Dry::Types["range"].of(Dry::Types["float"]) }

    it "detects invalid input of the completely wrong type" do
      expect(range.valid?(5)).to be(false)
    end

    it "detects invalid input of the wrong member type" do
      expect(range.valid?(1..2)).to be(false)
    end

    it "recognizes valid input" do
      expect(range.valid?(1.0..2.0)).to be(true)
    end
  end

  describe "#===" do
    subject(:range) { Dry::Types["strict.range"].of(Dry::Types["strict.integer"]) }

    it "returns boolean" do
      expect(range.===(1..2)).to eql(true)
      expect(range.===(1..2.0)).to eql(false)
    end

    context "in case statement" do
      let(:value) do
        case 1..2
        when range then "accepted"
        else "invalid"
        end
      end

      it "returns correct value" do
        expect(value).to eql("accepted")
      end
    end
  end

  context "member" do
    describe "#to_s" do
      subject(:type) { Dry::Types["nominal.range"].of(Dry::Types["nominal.string"]) }

      it "returns string representation of the type" do
        expect(type.to_s).to eql("#<Dry::Types[Range<Nominal<String>>]>")
      end

      it "shows meta" do
        expect(type.meta(foo: :bar).to_s).to eql("#<Dry::Types[Range<Nominal<String> meta={foo: :bar}>]>")
      end
    end

    describe "#constructor" do
      subject(:type) { Dry::Types["params.range<params.integer>"] }

      it "gets member from a constructor type" do
        expect(type.member.("1")).to be(1)
      end

      describe "#lax" do
        subject(:type) { Dry::Types["range<integer>"].constructor(&:to_a) }

        it "makes type recursively lax" do
          expect(type.lax.member).to eql(Dry::Types["nominal.integer"])
        end
      end

      describe "#constrained" do
        it "applies constraints on top of constructor" do
          expect(type.constrained(eql: 1..2).(1..2)).to eql(1..2)
          expect(type.constrained(eql: 1..2).(1..3) { :fallback }).to be(:fallback)
        end
      end
    end

    context "nested range" do
      let(:strings) do
        Dry::Types["range"].of("string")
      end

      subject(:type) do
        Dry::Types["range"].of(strings)
      end

      it "still discards constructor" do
        expect(type.constructor(&:to_a).member.type).to eql(strings)
      end
    end
  end

  describe "#to_s" do
    subject(:type) { Dry::Types["nominal.range"] }

    it "returns string representation of the type" do
      expect(type.to_s).to eql("#<Dry::Types[Range]>")
    end

    it "adds meta" do
      expect(type.meta(foo: :bar).to_s).to eql("#<Dry::Types[Range meta={foo: :bar}]>")
    end
  end
end
