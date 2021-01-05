# frozen_string_literal: true

require "dry/types/predicate_inferrer"
require "dry/types/predicate_registry"

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

  it "returns type?(type) for arbitrary types" do
    custom_type = Dry::Types::Nominal.new(double(:some_type, name: "ObjectID"))

    expect(inferrer[custom_type]).to eql([type?: custom_type.primitive])
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

    it "works with rules without additional parameters" do
      expect(inferrer[type(:integer).constrained([:odd])]).to eql([:int?, :odd?])
    end

    it "can extract many rules" do
      expect(
        inferrer[type(:integer).constrained(gteq: 18, lt: 100)]
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
end
