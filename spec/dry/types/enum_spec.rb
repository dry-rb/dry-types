# frozen_string_literal: true

RSpec.describe Dry::Types::Enum do
  context "with mapping" do
    subject(:type) { string.enum(mapping) }

    let(:mapping) { {"draft" => 0, "published" => 10, "archived" => 20} }
    let(:values) { mapping.keys }
    let(:string) { Dry::Types["strict.string"] }

    it_behaves_like Dry::Types::Nominal
    it_behaves_like "a constrained type"
    it_behaves_like "a composable constructor"

    it "allows defining an enum from a specific type" do
      expect(type["draft"]).to eql(mapping.key(0))
      expect(type["published"]).to eql(mapping.key(10))
      expect(type["archived"]).to eql(mapping.key(20))

      expect(type[0]).to be(mapping.key(0))
      expect(type[10]).to be(mapping.key(10))
      expect(type[20]).to eql(mapping.key(20))

      expect(type.mapping).to eql(mapping)

      expect { type["oops"] }.to raise_error(Dry::Types::ConstraintError, /oops/)

      expect(type.mapping).to be_frozen
    end

    it "works with optionals" do
      expect(type.optional["draft"]).to eql(mapping.key(0))
      expect(type.optional[0]).to be(mapping.key(0))
      expect(type.optional[nil]).to be nil
    end
  end

  context "with string type" do
    subject(:type) { string.enum(*values) }

    let(:values) { %w[draft published archived] }
    let(:string) { Dry::Types["strict.string"] }

    it_behaves_like Dry::Types::Nominal
    it_behaves_like "a composable constructor"

    it "allows defining an enum from a specific type" do
      expect(type["draft"]).to eql(values[0])
      expect(type["published"]).to eql(values[1])
      expect(type["archived"]).to eql(values[2])

      expect(type.values).to eql(values)

      expect { type["oops"] }.to raise_error(Dry::Types::ConstraintError, /oops/)

      expect(type.values).to be_frozen
    end

    describe "#===" do
      it "returns boolean" do
        expect(type.===("draft")).to eql(true)
        expect(type.===("deleted")).to eql(false)
      end

      context "in case statement" do
        let(:value) do
          case "draft"
          when type then "accepted"
          else "invalid"
          end
        end

        it "returns correct value" do
          expect(value).to eql("accepted")
        end
      end
    end

    it "allows defining an enum from a default-value type" do
      with_default = string.default("draft").enum(*values)

      expect(with_default.call).to eql("draft")
    end

    it "doesn't allows defining a default value for an enum" do
      expect {
        type.default("published")
      }.to raise_error(RuntimeError)
    end

    it "aliases #[] as #call" do
      expect(type.call("draft")).to eql(values[0])
    end
  end

  context "with int type" do
    subject(:type) { Dry::Types["nominal.integer"].enum(*values) }

    let(:values) { [2, 3, 4] }

    it_behaves_like Dry::Types::Nominal

    it "allows defining an enum from a specific type" do
      expect(type[2]).to be(2)
      expect(type[3]).to be(3)
      expect(type[4]).to be(4)

      expect(type.values).to eql(values)
    end
  end

  describe "#include?" do
    subject(:enum) { Dry::Types["nominal.integer"].enum(4, 5, 6) }

    it "returns true for input that is included in the values" do
      expect(enum.include?(5)).to be true
    end

    it "returns false for input that is not included in the values" do
      expect(enum.include?(7)).to be false
    end
  end

  describe "#try" do
    subject(:enum) { Dry::Types["nominal.integer"].enum(4, 5, 6) }

    it "returns a success result for valid input" do
      expect(enum.try(5)).to be_success
    end

    it "returns a failure result for invalid input" do
      expect(enum.try(7)).to be_failure
    end

    it "accepts a block for the fallback mechanism" do
      expect(enum.try(7) { 5 }).to be(5)
    end
  end

  describe "#with" do
    subject(:enum_with_meta) { Dry::Types["nominal.integer"].enum(4, 5, 6).meta(foo: :bar) }

    it_behaves_like Dry::Types::Nominal do
      let(:type) { enum_with_meta }
    end

    it "preserves metadata" do
      expect(enum_with_meta.meta).to eql(foo: :bar)
    end
  end

  describe "#to_s" do
    context "simple enumeration" do
      subject(:type) { Dry::Types["nominal.integer"].enum(4, 5, 6) }

      it "returns string representation of the type" do
        expect(type.to_s).to eql(
          "#<Dry::Types[Enum<Constrained<Nominal<Integer> " \
          "rule=[included_in?([4, 5, 6])]> values={4, 5, 6}>]>"
        )
      end
    end

    context "mapping" do
      let(:mapping) { {0 => "draft", 10 => "published", 20 => "archived"} }

      subject(:type) { Dry::Types["nominal.integer"].enum(mapping) }

      it "returns string representation of the type" do
        expect(type.to_s).to eql(
          "#<Dry::Types[Enum<Constrained<Nominal<Integer> " \
          "rule=[included_in?([0, 10, 20])]> " \
          'mapping={0=>"draft", 10=>"published", 20=>"archived"}>]>'
        )
      end
    end
  end

  describe "#each_value" do
    context "simple enumeration" do
      subject(:type) { Dry::Types["nominal.integer"].enum(4, 5, 6) }

      it "iterates over keys" do
        expect(type.each_value.to_a).to eql([4, 5, 6])
      end

      it "returns enumerator" do
        enumerator = type.each_value

        expect(enumerator.next).to be(type.values.first)
      end
    end

    context "mapping" do
      let(:mapping) { {0 => "draft", 10 => "published", 20 => "archived"} }

      subject(:type) { Dry::Types["nominal.integer"].enum(mapping) }

      it "returns the enum values" do
        expect(type.each_value.to_a).to eql([0, 10, 20])
      end

      it "returns enumerator" do
        enumerator = type.each_value

        expect(enumerator.next).to be(type.values.first)
      end
    end
  end

  describe "#constructor" do
    subject(:type) { Dry::Types["nominal.integer"].enum(4, 5) }

    it "builds a constructor type" do
      expect(type.constructor(&:to_i).mapping).to eql(4 => 4, 5 => 5)
    end
  end
end
