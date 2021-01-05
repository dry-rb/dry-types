# frozen_string_literal: true

RSpec.describe Dry::Types::Nominal do
  subject(:type) { Dry::Types::Nominal.new(String) }

  it_behaves_like "Dry::Types::Nominal#meta"
  it_behaves_like "a composable constructor"

  it "is frozen" do
    expect(type).to be_frozen
  end

  describe "#constructor" do
    it "returns a constructor" do
      coercible_string = type.constructor(&:to_s)

      expect(coercible_string[{}]).to eql({}.to_s)
    end
  end

  describe "#try" do
    it "always returns success, even for other types" do
      expect(type.try("string")).to be_success
      expect(type.try(Object.new)).to be_success
    end
  end

  describe "#try_coerce" do
    let(:result) { type.try_coerce(value) }

    context "when given valid input" do
      let(:value) { "foo" }

      it "returns a success" do
        expect(result).to be_success
      end

      it "provides the original input" do
        expect(result.input).to be(value)
      end
    end

    context "when given invalid input" do
      let(:value) { :foo }

      it "returns a failure" do
        expect(result).to be_failure
      end

      it "provides the original input" do
        expect(result.input).to be(value)
      end

      it "provides an error message" do
        expect(result.error.message).to eql(":foo must be an instance of String")
      end

      it "yields failure when given a block" do
        expect { |probe| type.try_coerce(value, &probe) }.to yield_with_args(result)
      end
    end

    describe "#===" do
      it "return if the value pass is valid primitive" do
        expect(type.===("hello")).to eql(true)
      end

      context "in case statement" do
        let(:value) do
          case "Hello"
          when type then "0_o"
          else 2
          end
        end

        it "use in case statement" do
          expect(value).to eql("0_o")
        end
      end
    end

    describe "#to_s" do
      let(:type) { Dry::Types["nominal.string"] }

      it "returns string representation of the type" do
        expect(type.to_s).to eql("#<Dry::Types[Nominal<String>]>")
      end
    end
  end
end
