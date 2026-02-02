# frozen_string_literal: true

RSpec.describe Dry::Types::Nominal, "#lax" do
  context "with a coercible string" do
    subject(:type) { Dry::Types["coercible.string"].constrained(min_size: 5).lax }

    it_behaves_like Dry::Types::Nominal

    it "rescues from type-errors and returns input" do
      expect(type["pass"]).to eql("pass")
    end

    it "tries to apply its type" do
      expect(type[:passing]).to eql("passing")
    end

    it "aliases #[] as #call" do
      expect(type.call(:passing)).to eql("passing")
    end
  end

  context "with a params hash" do
    subject(:type) do
      Dry::Types["params.hash"].schema(
        age: "coercible.integer", active: "params.bool"
      ).lax
    end

    it_behaves_like Dry::Types::Nominal

    it "applies its types" do
      expect(type[age: "23", active: "f"]).to eql(age: 23, active: false)
    end

    it "rescues from type-errors and returns input" do
      expect(type[age: "wat", active: "1"]).to eql(age: "wat", active: true)
    end

    it "doesn't decorate keys" do
      expect(type.key(:age)).to be_a(Dry::Types::Schema::Key)
      expect(type.key(:age).("23")).to eql(23)
    end

    context "wrapping constructors" do
      subject(:type) do
        Dry::Types["hash"].schema(age: age, active: "params.bool").lax
      end

      context "modification" do
        let(:age) do
          Dry::Types["coercible.integer"].constructor do |input, type|
            type.(input) + 1
          end
        end

        it "applies its types" do
          expect(type[age: "23", active: "f"]).to eql(age: 24, active: false)
        end
      end

      context "fallback" do
        let(:age) do
          Dry::Types["integer"].constrained(gteq: 18).fallback(18).meta(foo: :bar)
        end

        it "applies its types" do
          expect(type[age: "aa", active: "f"]).to eql(age: 18, active: false)
        end
      end
    end
  end

  context "with an array" do
    let(:source_type) { Dry::Types["array"].of(Dry::Types["coercible.integer"]) }

    subject(:type) { source_type.lax }

    it "rescues from type-errors and returns input" do
      expect(type[["1", :a, 30]]).to eql([1, :a, 30])
    end

    it "preserves meta" do
      expect(source_type.meta(foo: :bar).lax.meta).to eql(foo: :bar)
    end
  end

  describe "#to_s" do
    subject(:type) { Dry::Types["coercible.integer"].lax }

    it "returns string representation of the type" do
      expect(type.to_s).to eql(
        "#<Dry::Types[Lax<Constructor<Nominal<Integer> fn=Kernel.Integer>>]>"
      )
    end
  end

  describe "#try" do
    subject(:type) { Dry::Types["coercible.integer"].lax }

    it "delegates to underlying type" do
      expect(type.try("1")).to be_a(Dry::Types::Result::Success)
      expect(type.try("a")).to be_a(Dry::Types::Result::Failure)
    end
  end

  describe "#lax" do
    subject(:type) { Dry::Types["coercible.integer"].lax }

    specify do
      expect(type.lax).to be(type)
    end
  end

  context "with lax sum type containing array" do
    # Regression spec for JRuby bug where yield + &block + each_with_object
    # causes incorrect block argument passing (returns first element instead of array)
    # see: https://github.com/jruby/jruby/issues/9208
    it "returns partial coercion result when array member coercion fails" do
      int_type = Dry::Types["params.integer"]
      array_type = Dry::Types["params.array"].of(Dry::Types["params.integer"])
      sum_type = int_type | array_type
      lax_type = sum_type.lax

      input = ["1", nil, "3"]
      result = lax_type.call(input)

      expect(result).to eq([1, nil, 3])
    end
  end
end
