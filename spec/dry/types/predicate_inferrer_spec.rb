# frozen_string_literal: true

RSpec.describe Dry::Types::PredicateInferrer, "#[]" do
  subject(:inferrer) do
    Dry::Types::PredicateInferrer.new(Dry::Types::PredicateRegistry.new)
  end

  def type(*args)
    args.map { |name| Dry::Types[name.to_s] }.reduce(:|)
  end

  it "caches results" do
    expect(inferrer[type(:string)]).to be(inferrer[type(:string)])
  end

  it "returns array? for an array type" do
    expect(inferrer[type(:array)]).to eql([:array?])
  end

  it "returns array? for an array type with member" do
    expect(inferrer[type(:array).of(type(:integer))]).to eql([:array?])
  end

  it "returns str? for a string type" do
    expect(inferrer[type(:string)]).to eql([:str?])
  end

  it "returns str? for a string nominal type" do
    expect(inferrer[type("nominal.string")]).to eql([:str?])
  end

  it "returns int? for a integer type" do
    expect(inferrer[type(:integer)]).to eql([:int?])
  end

  it "returns date_time? for a datetime type" do
    expect(inferrer[type(:date_time)]).to eql([:date_time?])
  end

  it "returns nil? for a nil type" do
    expect(inferrer[type(:nil)]).to eql([:nil?])
  end

  it "returns true? for a true type" do
    expect(inferrer[type(:true)]).to eql([:true?])
  end

  it "returns false? for a false type" do
    expect(inferrer[type(:false)]).to eql([:false?])
  end

  it "returns bool? for bool type" do
    expect(inferrer[type(:bool)]).to eql([:bool?])
  end

  it "returns date? for date type" do
    expect(inferrer[type(:date)]).to eql([:date?])
  end

  it "returns float? for float type" do
    expect(inferrer[type(:float)]).to eql([:float?])
  end

  it "returns time? for time type" do
    expect(inferrer[type(:time)]).to eql([:time?])
  end

  it "returns decimal? or str? for a sum type" do
    expect(inferrer[type(:decimal) | type(:string)]).to eql([[[:decimal?], [:str?]]])
  end

  it "returns int? for a lax constructor integer type" do
    expect(inferrer[type("params.integer").lax]).to eql([:int?])
  end

  it "returns :int? from an optional integer with constructor" do
    expect(inferrer[type(:integer).optional.constructor(&:to_i)]).to eql([:int?])
  end

  it "returns int? for integer enum type" do
    expect(inferrer[type(:integer).enum(1, 2)]).to eql([:int?, included_in?: [1, 2]])
  end

  it "returns nothing for any" do
    expect(inferrer[type(:any)]).to eql([])
  end

  it "returns hash? for hash" do
    expect(inferrer[type(:hash)]).to eql([:hash?])
  end

  # it is a compromise
  # inferring complex schemas as predicates
  # is not our goal at this point
  it "returns hash? for schemas" do
    expect(inferrer[type(:hash).schema(name: "string")]).to eql([:hash?])
  end

  context "constrained types" do
    it "extracts predicates from contrained types" do
      expect(inferrer[type(:integer).constrained(gteq: 18)]).to eql([:int?, gteq?: 18])
    end

    it "works with nullary rules" do
      expect(inferrer[type(:integer).constrained(:odd, :even)]).to eql([:int?, :odd?, :even?])
    end

    it "works with array of nullary rules" do
      expect(inferrer[type(:integer).constrained([:odd, :even])]).to eql([:int?, :odd?, :even?])
    end

    it "works with combination of nullary and unary rules" do
      expect(
        inferrer[type(:integer).constrained(:odd, gteq: 18, lt: 100)]
      ).to eql([:int?, :odd?, gteq?: 18, lt?: 100])
    end

    it "works with array of nullary rules with unary rules" do
      expect(
        inferrer[type(:integer).constrained([:odd, :even], gteq: 18, lt: 100)]
      ).to eql([:int?, :odd?, :even?, gteq?: 18, lt?: 100])
    end

    it "works with hash of unary rules" do
      expect(
        inferrer[type(:integer).constrained({gteq: 18, lt: 100})]
      ).to eql([:int?, gteq?: 18, lt?: 100])
    end

    it "infers chained types" do
      expect(
        inferrer[type(:integer).constrained([:odd]).constrained(gteq: 18, lt: 100)]
      ).to eql([:int?, :odd?, gteq?: 18, lt?: 100])

      expect(
        inferrer[type(:integer).constrained(gteq: 18, lt: 100).constrained([:odd])]
      ).to eql([:int?, :odd?, gteq?: 18, lt?: 100])
    end

    it "works with complex case" do
      type = type(:integer).constrained(gteq: 18) | type(:string).constrained(min_size: 3)

      expect(inferrer[type]).to eql([[[:int?, gteq?: 18], [:str?, min_size?: 3]]])
    end

    describe "unknown predicate" do
      subject(:inferrer) do
        Dry::Types::PredicateInferrer.new(int?: true)
      end

      it "ignores unknown predicates" do
        expect(inferrer[type(:integer).constrained(gteq: 99_999)]).to eql([:int?])
      end
    end
  end

  describe "inferring predicates based on class names" do
    it "is deprecated by default" do
      custom_type = Dry::Types::Nominal.new(double(:some_type, name: "URI"))

      expect { inferrer[custom_type] }.to raise_error(
        KeyError, /Automatic predicate inferring from class names is deprecated/
      )
    end

    context "disabled" do
      around do |ex|
        Dry::Types::PredicateInferrer::Compiler.infer_predicate_by_class_name false
        ex.run
        Dry::Types::PredicateInferrer::Compiler.infer_predicate_by_class_name nil
      end

      it "can be turned off" do
        require "uri"
        custom_type = Dry::Types::Nominal.new(URI)

        expect(inferrer[custom_type]).to eql([type?: URI])
      end
    end

    context "enabled" do
      around do |ex|
        Dry::Types::PredicateInferrer::Compiler.infer_predicate_by_class_name true
        ex.run
        Dry::Types::PredicateInferrer::Compiler.infer_predicate_by_class_name nil
      end

      it "should be removed once 2.0 is released" do
        if Dry::Types::VERSION.start_with?("2.")
          raise "Remove infer_predicate_by_class_name"
        end
      end

      specify do
        custom_type = Dry::Types::Nominal.new(double(:some_type, name: "ObjectID"))

        expect(inferrer[custom_type]).to eql([type?: custom_type.primitive])
      end
    end

    example "anonymous class" do
      custom_type = Dry::Types::Nominal.new(Class.new)

      expect(inferrer[custom_type]).to eql([type?: custom_type.primitive])
    end
  end

  it "tells that map types are not supported" do
    expect {
      inferrer[type(:hash).map("integer", "string")]
    }.to raise_error(NotImplementedError, /map types are not supported/)
  end
end
