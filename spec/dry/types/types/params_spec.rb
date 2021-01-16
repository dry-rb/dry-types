# frozen_string_literal: true

RSpec.describe Dry::Types::Nominal do
  describe "params.nil" do
    subject(:type) { Dry::Types["params.nil"] }

    it_behaves_like "a constrained type", inputs: [Object.new, %w[foo]]

    it "coerces empty string to nil" do
      expect(type[""]).to be(nil)
    end
  end

  describe "params.nil | params.integer" do
    subject(:type) { Dry::Types["params.nil"] | Dry::Types["params.integer"] }

    it_behaves_like "a constrained type"

    it "coerces empty string to nil" do
      expect(type[""]).to be(nil)
    end

    it "coerces string to an integer" do
      expect(type["23"]).to be(23)
    end
  end

  describe "params.date" do
    subject(:type) { Dry::Types["params.date"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "not-a-date", "12345678912/04/2017"
    ]

    it "coerces to a date" do
      expect([
        type["2015-11-26"],
        type["H27.11.26"],
        type["Thu, 26 Nov 2015 00:00:00 GMT"]
      ]).to all(eql(Date.new(2015, 11, 26)))
    end

    it "accepts date" do
      date = Date.new(2015, 11, 26)

      expect(type[date]).to be(date)
    end
  end

  describe "params.date_time" do
    subject(:type) { Dry::Types["params.date_time"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "not-a-date-time"
    ]

    it "coerces to a date time" do
      expect(type["2015-11-26 12:00:00"]).to eql(DateTime.new(2015, 11, 26, 12))
    end

    it "accepts datetime" do
      datetime = DateTime.new(2015, 11, 26, 12)
      expect(type[datetime]).to be(datetime)
    end
  end

  describe "params.time" do
    subject(:type) { Dry::Types["params.time"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "not-a-time"
    ]

    it "coerces to a time" do
      expect(type["2015-11-26 12:00:00"]).to eql(Time.new(2015, 11, 26, 12))
    end

    it "accepts time" do
      time = Time.new(2015, 11, 26, 12)
      expect(type[time]).to be(time)
    end
  end

  describe "params.bool" do
    subject(:type) { Dry::Types["params.bool"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "huh?"
    ]
    it_behaves_like "a composable constructor"

    it "coerces to true" do
      (Dry::Types::Coercions::Params::TRUE_VALUES + [1]).each do |value|
        expect(type[value]).to be(true)
      end
    end

    it "coerces to false" do
      (Dry::Types::Coercions::Params::FALSE_VALUES + [0]).each do |value|
        expect(type[value]).to be(false)
      end
    end

    it "accepts true and false" do
      expect(type[true]).to be(true)
      expect(type[false]).to be(false)
    end
  end

  describe "params.true" do
    subject(:type) { Dry::Types["params.true"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "huh?"
    ]

    it "coerces to true" do
      %w[1 on t true y yes].each do |value|
        expect(type[value]).to be(true)
      end
    end

    it "accepts true" do
      expect(type[true]).to be(true)
    end
  end

  describe "params.false" do
    subject(:type) { Dry::Types["params.false"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "huh?"
    ]

    it "coerces to false" do
      %w[0 off f false n no].each do |value|
        expect(type[value]).to be(false)
      end
    end

    it "accepts false" do
      expect(type[false]).to be(false)
    end
  end

  describe "params.integer" do
    subject(:type) { Dry::Types["params.integer"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "foo", "23asf", {}
    ]

    it "coerces to an integer" do
      expect(type["312"]).to be(312)
      expect(type["0"]).to eql(0)
    end

    it "coerces string with leading zero to an integer using 10 as a default base" do
      expect(type["010"]).to be(10)
    end
  end

  describe "params.float" do
    subject(:type) { Dry::Types["params.float"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "foo", "23asd", {}
    ]

    it "coerces to a float" do
      expect(type["3.12"]).to eql(3.12)
    end

    it "coerces zero values" do
      expect(type["0.0"]).to eql(0.0)
      expect(type["0"]).to eql(0.0)
    end
  end

  describe "params.decimal" do
    subject(:type) { Dry::Types["params.decimal"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "foo", "23asf", {}
    ]

    it "coerces to a decimal" do
      expect(type["3.12"]).to eql(BigDecimal("3.12"))
    end

    it "does not lose precision of the original value" do
      expect(type["0.66666666666666666667"]).to eql(BigDecimal("0.66666666666666666667"))
    end

    it "coerces Float to BigDecimal without complaining about precision" do
      expect(type[3.12]).to eql(BigDecimal("3.12"))
    end
  end

  describe "params.array" do
    subject(:type) { Dry::Types["params.array"].of(Dry::Types["params.integer"]) }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "foo", "23asf", {}
    ]

    it "returns coerced array" do
      arr = %w[1 2 3]
      expect(type[arr]).to eql([1, 2, 3])
    end

    it "coerces an empty string into an empty array" do
      input = ""
      expect(type[input]).to eql([])
    end
  end

  describe "params.hash" do
    subject(:type) { Dry::Types["params.hash"].schema(age: Dry::Types["params.integer"]) }

    it_behaves_like "a constrained type", inputs: [
      Object.new, "foo", "23asf", []
    ]

    it "returns coerced hash" do
      hash = {age: "21"}
      expect(type[hash]).to eql(age: 21)
    end

    it "coerces an empty string into an empty hash" do
      type = Dry::Types["params.hash"]
      input = ""

      expect(type[input]).to eql({})

      type = Dry::Types["params.hash"].schema({})
      expect(type[input]).to eql({})
    end
  end

  describe "params.symbol" do
    subject(:type) { Dry::Types["params.symbol"] }

    it_behaves_like "a constrained type", inputs: [
      Object.new, 1
    ]

    it "coerces to a symbol" do
      expect(type["a"]).to eql(:a)
    end
  end

  describe "params.string" do
    subject(:type) { Dry::Types["params.string"] }

    it "is equal to strict.string" do
      expect(type).to be(Dry::Types["string"])
    end
  end

  context "optional types" do
    subject(:type) { Dry::Types["optional.params.integer"] }

    it "coerces empty strings to nil" do
      expect(type[""]).to be_nil
    end

    it "parses integers" do
      expect(type["40"]).to be(40)
    end

    it "raises an error on random strings" do
      expect { type["abc"] }.to raise_error(Dry::Types::CoercionError)
    end
  end
end
