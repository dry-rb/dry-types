# frozen_string_literal: true

RSpec.describe Dry::Types::Intersection do
  let(:t) { Dry.Types }

  let(:callable_type) { t.Interface(:call) }
  let(:procable_type) { t.Interface(:to_proc) }
  let(:function_type) { callable_type & procable_type }

  describe "common nominal behavior" do
    subject(:type) { function_type }

    it_behaves_like "Dry::Types::Nominal#meta"
    it_behaves_like "Dry::Types::Nominal without primitive"
    it_behaves_like "a composable constructor"

    it "is frozen" do
      expect(type).to be_frozen
    end
  end

  it_behaves_like "a constrained type" do
    let(:type) { function_type }

    it_behaves_like "a composable constructor"
  end

  describe "#[]" do
    it "works with two pass-through types" do
      type = t::Nominal::Hash & t.Hash(foo: t::Nominal::Integer)

      expect(type[{foo: ""}]).to eq({foo: ""})
      expect(type[{foo: 312}]).to eq({foo: 312})
    end

    it "works with two strict types" do
      type = t::Strict::Hash & t.Hash(foo: t::Strict::Integer)

      expect(type[{foo: 312}]).to eq({foo: 312})

      expect { type[312] }.to raise_error(Dry::Types::CoercionError)
    end

    it "is aliased as #call" do
      type = t::Nominal::Hash & t.Hash(foo: t::Nominal::Integer)

      expect(type.call({foo: ""})).to eq({foo: ""})
      expect(type.call({foo: 312})).to eq({foo: 312})
    end

    it "works with two constructor & constrained types" do
      left = t.Array(t::Strict::Hash)
      right = t.Array(t.Hash(foo: t::Nominal::Integer))

      type = left & right

      expect(type[[{foo: 312}]]).to eql([{foo: 312}])
    end

    it "works with two complex types with constraints" do
      type =
        t
          .Array(t.Array(t::Coercible::String.constrained(min_size: 5)).constrained(size: 2))
          .constrained(min_size: 1) &
        t
          .Array(t.Array(t::Coercible::String.constrained(format: /foo/)).constrained(size: 2))
          .constrained(min_size: 2)

      expect(type.([%w[foofoo barfoo], %w[bazfoo fooqux]])).to eql(
        [%w[foofoo barfoo], %w[bazfoo fooqux]]
      )

      expect { type[:oops] }.to raise_error(Dry::Types::ConstraintError, /:oops/)

      expect { type[[]] }.to raise_error(Dry::Types::ConstraintError, /\[\]/)

      expect { type.([%i[foo]]) }.to raise_error(Dry::Types::ConstraintError, /\[:foo\]/)

      expect { type.([[1], [2]]) }.to raise_error(Dry::Types::ConstraintError, /2, \[1\]/)

      expect { type.([%w[foofoo barfoo], %w[bazfoo foo]]) }.to raise_error(
        Dry::Types::ConstraintError,
        /min_size\?\(5, "foo"\)/
      )
    end
  end

  describe "#try" do
    subject(:type) { function_type }

    it "returns success when value passed" do
      expect(type.try(-> {})).to be_success
    end

    it "returns failure when value did not pass" do
      expect(type.try(:foo)).to be_failure
    end
  end

  describe "#success" do
    subject(:type) { function_type }

    it "returns success when value passed" do
      expect(type.success(-> {})).to be_success
    end

    it "raises ArgumentError when non of the types have a valid input" do
      expect { type.success("foo") }.to raise_error(ArgumentError, /Invalid success value 'foo' /)
    end
  end

  describe "#failure" do
    subject(:type) { Dry::Types["integer"] & Dry::Types["string"] }

    it "returns failure when invalid value is passed" do
      expect(type.failure(true)).to be_failure
    end
  end

  describe "#===" do
    subject(:type) { function_type }

    it "returns boolean" do
      expect(type.===(-> {})).to eql(true)
      expect(type.===(nil)).to eql(false) # rubocop:disable Style/NilComparison
    end

    context "in case statement" do
      let(:value) do
        case -> {}
        when type
          "accepted"
        else
          "invalid"
        end
      end

      it "returns correct value" do
        expect(value).to eql("accepted")
      end
    end
  end

  describe "#default" do
    it "returns a default value intersection type" do
      type = (t::Nominal::Nil & t::Nominal::Nil).default("foo")

      expect(type.call).to eql("foo")
    end
  end

  describe "#constructor" do
    let(:type) do
      (t::Nominal::String & t::Nominal::Nil).constructor do |input|
        input ? "#{input} world" : input
      end
    end

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
    let(:type) { function_type }

    it "returns a rule" do
      rule = type.rule

      expect(rule.(-> {})).to be_success
      expect(rule.(nil)).to be_failure
    end
  end

  describe "#to_s" do
    context "shallow intersection" do
      let(:type) { t::Nominal::String & t::Nominal::Integer }

      it "returns string representation of the type" do
        expect(type.to_s).to eql("#<Dry::Types[Intersection<Nominal<String> & Nominal<Integer>>]>")
      end
    end

    context "intersection tree" do
      let(:type) { t::Nominal::String & t::Nominal::Integer & t::Nominal::Date & t::Nominal::Time }

      it "returns string representation of the type" do
        expect(type.to_s).to eql(
          "#<Dry::Types[Intersection<" \
            "Nominal<String> & " \
            "Nominal<Integer> & " \
            "Nominal<Date> & " \
            "Nominal<Time>" \
            ">]>"
        )
      end
    end
  end

  context "with map type" do
    let(:map_type) { t::Nominal::Hash.map(t::Nominal::Symbol, t::Nominal::String) }

    let(:schema_type) { t.Hash(foo: t::Strict::String) }

    subject(:type) { map_type & schema_type }

    it "rejects invalid input" do
      expect(type.valid?({foo: 1, bar: 1})).to be false
      expect { type[{foo: 1, bar: 1}] }.to raise_error(Dry::Types::SchemaError)
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
