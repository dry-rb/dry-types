# frozen_string_literal: true

# rubocop:disable Style/YodaCondition

RSpec.describe Dry::Types::Implication do
  let(:t) { Dry.Types }

  let(:role_id_schema) { t.Hash(id: t::Strict::String) }
  let(:role_title_schema) { t.Hash(title: t::Strict::String) }
  let(:role_schema) { role_id_schema > role_title_schema }

  describe "common nominal behavior" do
    subject(:type) { role_schema }

    it_behaves_like "Dry::Types::Nominal#meta"
    it_behaves_like "Dry::Types::Nominal without primitive"
    it_behaves_like "a composable constructor"

    it "is frozen" do
      expect(type).to be_frozen
    end
  end

  describe "#[]" do
    it "works with two pass-through types" do
      type = t::Nominal::Hash > t.Hash(foo: t::Nominal::Integer)

      expect(type[{foo: ""}]).to eql({foo: ""})
      expect(type[{foo: 312}]).to eql({foo: 312})
    end

    it "works with two strict types" do
      type = t::Strict::Hash > t.Hash(foo: t::Strict::Integer)

      expect(type[{foo: 312}]).to eql({foo: 312})

      expect { type[{foo: "312"}] }.to raise_error(Dry::Types::CoercionError)
    end

    it "is aliased as #call" do
      type = t::Nominal::Hash > t.Hash(foo: t::Nominal::Integer)

      expect(type.call({foo: ""})).to eql({foo: ""})
      expect(type.call({foo: 312})).to eql({foo: 312})
    end

    it "works with two constructor & constrained types" do
      left = t.Array(t::Strict::Hash)
      right = t.Array(t.Hash(foo: t::Nominal::Integer))

      type = left > right

      expect(type[[{foo: 312}]]).to eql([{foo: 312}])
    end

    it "works with two complex types with constraints" do
      type =
        t
          .Array(t.Array(t::Coercible::String.constrained(min_size: 5)).constrained(size: 2))
          .constrained(min_size: 1) >
        t
          .Array(t.Array(t::Coercible::String.constrained(format: /foo/)).constrained(size: 2))
          .constrained(min_size: 2)

      expect(type.([%w[foofoo barfoo], %w[bazfoo fooqux]])).to eql(
        [%w[foofoo barfoo], %w[bazfoo fooqux]]
      )

      expect { type[[["hello there", "my friend"]]] }.to raise_error(Dry::Types::ConstraintError, /min_size\?\(2/)

      expect { type[[%w[hello there], ["my good", "friend"]]] }.to raise_error(Dry::Types::ConstraintError, %r{/foo/})
    end
  end

  describe "#try" do
    subject(:type) { role_schema }

    it "returns success when value passed" do
      expect(type.try({id: "id", title: "title"})).to be_success
    end

    it "returns failure when value did not pass" do
      expect(type.try({id: "id"})).to be_failure
    end
  end

  describe "#success" do
    subject(:type) { role_schema }

    it "returns success when value passed" do
      expect(type.success({id: "id", title: "title"})).to be_success
    end

    it "raises ArgumentError when non of the types have a valid input" do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect { type.success({id: "id"}) }.to raise_error(ArgumentError, /Invalid success value '{id: "id"}'/)
      else
        expect { type.success({id: "id"}) }.to raise_error(ArgumentError, /Invalid success value '\{:id=>"id"\}':/)
      end
    end
  end

  describe "#failure" do
    subject(:type) { t::Strict::Integer > t::Strict::String }

    it "returns failure when invalid value is passed" do
      expect(type.failure(1)).to be_failure
    end
  end

  describe "#===" do
    subject(:type) { role_schema }

    it "returns boolean" do
      expect(type.===({id: "id", title: "title"})).to eql(true)
      expect(type.===({id: "id"})).to eql(false)
    end

    context "in case statement" do
      let(:value) do
        case {id: "id", title: "title"}
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
    it "returns a default value implication type" do
      type = (t::Nominal::Nil > t::Nominal::Nil).default("foo")

      expect(type.call).to eql("foo")
    end
  end

  describe "#constructor" do
    let(:type) do
      (t::Nominal::String > t::Nominal::Nil).constructor do |input|
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
    let(:type) { t::Strict::Integer > t::Strict::String }

    it "returns a rule" do
      rule = type.rule

      expect(rule.(true)).to be_success
      expect(rule.(1)).to be_failure
    end
  end

  describe "#to_s" do
    context "shallow implication" do
      let(:type) { t::Nominal::String > t::Nominal::Integer }

      it "returns string representation of the type" do
        expect(type.to_s).to eql("#<Dry::Types[Implication<Nominal<String> > Nominal<Integer>>]>")
      end
    end

    context "constrained" do
      let(:type) { t::Nominal::String.constrained(format: /foo/) > t::Nominal::String.constrained(min_size: 4) }

      it "returns string representation of the type" do
        expect(type.to_s).to eql(
          "#<Dry::Types[Implication<" \
          "Constrained<Nominal<String> rule=[format?(/foo/)]> > " \
          "Constrained<Nominal<String> rule=[min_size?(4)]>>]>"
        )
      end
    end

    context "implication tree" do
      let(:type) { t::Nominal::String > (t::Nominal::Integer > (t::Nominal::Date > t::Nominal::Time)) }

      it "returns string representation of the type" do
        expect(type.to_s).to eql(
          "#<Dry::Types[Implication<" \
          "Nominal<String> > " \
          "Nominal<Integer> > " \
          "Nominal<Date> > " \
          "Nominal<Time>" \
          ">]>"
        )
      end
    end
  end

  context "with map type" do
    let(:map_type) { t::Nominal::Hash.map(t::Nominal::Symbol, t::Nominal::String) }

    let(:schema_type) { t.Hash(foo: t::Strict::String) }

    subject(:type) { map_type > schema_type }

    it "rejects invalid input" do
      expect(type.valid?({foo: 1, bar: 1})).to be false
      expect { type[{foo: 1, bar: 1}] }.to raise_error(Dry::Types::SchemaError)
    end
  end

  describe "#meta" do
    context "optional types" do
      let(:meta) { {foo: :bar} }

      subject(:type) { t::Nominal::String.optional }

      it "uses meta from the right branch" do
        expect(type.meta(meta).meta).to eql(meta)
        expect(type.meta(meta).right.meta).to eql(meta)
      end
    end
  end
end

# rubocop:enable Style/YodaCondition
