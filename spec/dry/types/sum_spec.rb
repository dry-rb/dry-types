# frozen_string_literal: true

RSpec.describe Dry::Types::Sum do
  describe "common nominal behavior" do
    subject(:type) { Dry::Types["bool"] }

    it_behaves_like "Dry::Types::Nominal#meta"
    it_behaves_like "Dry::Types::Nominal without primitive"
    it_behaves_like "a composable constructor"

    it "is frozen" do
      expect(type).to be_frozen
    end
  end

  it_behaves_like "a constrained type" do
    let(:type) { Dry::Types["integer"] | Dry::Types["string"] }

    it_behaves_like "a composable constructor"
  end

  describe "#optional?" do
    it "return true if left side is nil" do
      type = Dry::Types["strict.nil"] | Dry::Types["nominal.string"]

      expect(type).to be_optional
    end

    it "return true if right side is nil" do
      type = Dry::Types["nominal.string"] | Dry::Types["nominal.nil"]

      expect(type).to be_optional
    end

    it "works when left is a Sum type" do
      type = Dry::Types["strict.integer"] | Dry::Types["strict.date"] | Dry::Types["strict.string"]

      expect(type).to_not be_optional
    end
  end

  describe "#[]" do
    it "works with two pass-through types" do
      type = Dry::Types["nominal.integer"] | Dry::Types["nominal.string"]

      expect(type[312]).to be(312)
      expect(type["312"]).to eql("312")
      expect(type[nil]).to be(nil)
    end

    it "works with two strict types" do
      type = Dry::Types["integer"] | Dry::Types["string"]

      expect(type[312]).to be(312)
      expect(type["312"]).to eql("312")

      expect { type[{}] }.to raise_error(Dry::Types::CoercionError)
    end

    it "works with nil and strict types" do
      type = Dry::Types["strict.nil"] | Dry::Types["strict.string"]

      expect(type[nil]).to be(nil)
      expect(type["312"]).to eql("312")

      expect { type[{}] }.to raise_error(Dry::Types::CoercionError)
    end

    it "is aliased as #call" do
      type = Dry::Types["nominal.integer"] | Dry::Types["nominal.string"]
      expect(type.call(312)).to be(312)
      expect(type.call("312")).to eql("312")
    end

    it "works with two constructor & constrained types" do
      left = Dry::Types["array<string>"]
      right = Dry::Types["array<hash>"]

      type = left | right

      expect(type[%w[foo bar]]).to eql(%w[foo bar])

      expect(type[[{name: "foo"}, {name: "bar"}]]).to eql([
        {name: "foo"}, {name: "bar"}
      ])
    end

    it "works with two complex types with constraints" do
      pair = Dry::Types["array"]
        .of(Dry::Types["coercible.string"])
        .constrained(size: 2)

      string_list = Dry::Types["array"]
        .of(Dry::Types["string"])
        .constrained(min_size: 1)

      string_pairs = Dry::Types["array"]
        .of(pair)
        .constrained(min_size: 1)

      type = string_list | string_pairs

      expect(type.(%w[foo])).to eql(%w[foo])
      expect(type.(%w[foo bar])).to eql(%w[foo bar])

      expect(type.([[1, "foo"], [2, "bar"]])).to eql([%w[1 foo], %w[2 bar]])

      expect { type[:oops] }.to raise_error(Dry::Types::ConstraintError, /:oops/)

      expect { type[[]] }.to raise_error(Dry::Types::ConstraintError, /\[\]/)

      expect { type.([%i[foo]]) }.to raise_error(Dry::Types::ConstraintError, /\[:foo\]/)

      expect { type.([[1], [2]]) }.to raise_error(Dry::Types::ConstraintError, /[1]/)
      expect { type.([[1], [2]]) }.to raise_error(Dry::Types::ConstraintError, /[2]/)
    end
  end

  describe "#try" do
    subject(:type) { Dry::Types["strict.bool"] }

    it "returns success when value passed" do
      expect(type.try(true)).to be_success
    end

    it "returns failure when value did not pass" do
      expect(type.try("true")).to be_failure
    end
  end

  describe "#success" do
    subject(:type) { Dry::Types["strict.bool"] }

    it "returns success when value passed" do
      expect(type.success(true)).to be_success
    end

    it "raises ArgumentError when non of the types have a valid input" do
      expect {
        type.success("true")
      }.to raise_error(ArgumentError, /Invalid success value 'true'/)
    end
  end

  describe "#failure" do
    subject(:type) { Dry::Types["integer"] | Dry::Types["string"] }

    it "returns failure when invalid value is passed" do
      expect(type.failure(true)).to be_failure
    end
  end

  describe "#===" do
    subject(:type) { Dry::Types["integer"] | Dry::Types["string"] }

    it "returns boolean" do
      expect(type.===("hello")).to eql(true)
      expect(type.===(nil)).to eql(false)
    end

    context "in case statement" do
      let(:value) do
        case "world"
        when type then "accepted"
        else "invalid"
        end
      end

      it "returns correct value" do
        expect(value).to eql("accepted")
      end
    end
  end

  describe "#default" do
    it "returns a default value sum type" do
      type = (Dry::Types["nominal.nil"] | Dry::Types["nominal.string"]).default("foo")

      expect(type.call).to eql("foo")
    end

    it "supports a sum type which includes a constructor type" do
      type = (Dry::Types["params.nil"] | Dry::Types["params.integer"]).default(3)
      expect(type[""]).to be(nil)
    end

    it "supports a sum type which includes a constrained constructor type" do
      type = (Dry::Types["strict.nil"] | Dry::Types["coercible.integer"]).default(3)

      expect(type[]).to be(3)
      expect(type["3"]).to be(3)
      expect(type["7"]).to be(7)
    end
  end

  describe "#constructor" do
    let(:type) { (Dry::Types["nominal.string"] | Dry::Types["nominal.nil"]).constructor { |input| input ? input.to_s + " world" : input } }

    it "returns the correct value" do
      expect(type.call("hello")).to eql("hello world")
      expect(type.call(nil)).to eql(nil)
      expect(type.call(10)).to eql("10 world")
    end

    it "returns if value is valid" do
      expect(type.valid?("hello")).to eql(true)
      expect(type.valid?(nil)).to eql(true)
      expect(type.valid?(10)).to eql(true)
    end
  end

  describe "#rule" do
    let(:two_addends) { Dry::Types["strict.nil"] | Dry::Types["strict.string"] }

    shared_examples_for "a disjunction of constraints" do
      it "returns a rule" do
        rule = type.rule

        expect(rule.(nil)).to be_success
        expect(rule.("1")).to be_success
        expect(rule.(1)).to be_failure
      end
    end

    it_behaves_like "a disjunction of constraints" do
      subject(:type) { two_addends }
    end

    it_behaves_like "a disjunction of constraints" do
      subject(:type) { Dry::Types["strict.true"] | two_addends }

      it "accepts true" do
        rule = type.rule

        expect(rule.(true)).to be_success
        expect(rule.(false)).to be_failure
      end
    end

    it_behaves_like "a disjunction of constraints" do
      subject(:type) { two_addends | Dry::Types["strict.true"] }

      it "accepts true" do
        rule = type.rule

        expect(rule.(true)).to be_success
        expect(rule.(false)).to be_failure
      end
    end
  end

  describe "#to_s" do
    context "shallow sum" do
      let(:type) { Dry::Types["nominal.string"] | Dry::Types["nominal.integer"] }

      it "returns string representation of the type" do
        expect(type.to_s).to eql("#<Dry::Types[Sum<Nominal<String> | Nominal<Integer>>]>")
      end
    end

    context "sum tree" do
      let(:type) do
        Dry::Types["nominal.string"] | Dry::Types["nominal.integer"] |
          (Dry::Types["nominal.date"] | Dry::Types["nominal.time"])
      end

      it "returns string representation of the type" do
        expect(type.to_s).to eql(
          "#<Dry::Types[Sum<"\
          "Nominal<String> | "\
          "Nominal<Integer> | "\
          "Nominal<Date> | "\
          "Nominal<Time>"\
          ">]>"
        )
      end
    end
  end

  context "with map type" do
    let(:map_type) do
      Dry::Types["hash"].map(Dry::Types["symbol"], Dry::Types["string"])
    end

    let(:string_type) { Dry::Types["string"] }

    subject(:type) { map_type | string_type }

    it "rejects invalid input" do
      expect(type.valid?(12_345)).to be false
      expect { type[12_345] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe "#meta" do
    context "optional types" do
      let(:meta) { {foo: :bar} }

      subject(:type) { Dry::Types["string"].optional }

      it "uses meta from the right branch" do
        expect(type.meta(meta).meta).to eql(meta)
        expect(type.meta(meta).right.meta).to eql(meta)
      end
    end
  end
end
