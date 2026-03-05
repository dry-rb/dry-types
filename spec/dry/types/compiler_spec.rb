# frozen_string_literal: true

RSpec.describe Dry::Types::Compiler, "#call" do
  subject(:compiler) { Dry::Types::Compiler.new(Dry::Types) }

  it "returns existing nominal" do
    ast = [:nominal, [Hash, {}, {}]]
    type = compiler.(ast)

    expect(type).to be(Dry::Types["nominal.hash"])
  end

  it "returns existing nominal" do
    ast = [:nominal, [Hash, {}]]
    type = compiler.(ast)

    expect(type).to be(Dry::Types["nominal.hash"])
  end

  it "builds a plain nominal" do
    ast = [:nominal, [Set, {}, {}]]
    type = compiler.(ast)
    expected = Dry::Types::Nominal.new(Set)

    expect(type).to eql(expected)
  end

  it "builds a nominal with meta" do
    ast = [:nominal, [Set, {}, {key: :value}]]
    type = compiler.(ast)
    expected = Dry::Types::Nominal.new(Set, meta: {key: :value})

    expect(type).to eql(expected)
  end

  it "builds a coercible hash" do
    ast = Dry::Types["nominal.hash"].schema(
      email: Dry::Types["nominal.string"],
      age: Dry::Types["params.integer"],
      admin: Dry::Types["params.bool"],
      address: Dry::Types["nominal.hash"].schema(
        city: Dry::Types["nominal.string"],
        street: Dry::Types["nominal.string"]
      )
    ).to_ast

    hash = compiler.(ast)

    expect(hash).to be_a(Dry::Types::Hash)

    result = hash[
      email: "jane@doe.org",
      age: "20",
      admin: "1",
      address: {city: "NYC", street: "Street 1/2"}
    ]

    expect(result).to eql(
      email: "jane@doe.org", age: 20, admin: true,
      address: {city: "NYC", street: "Street 1/2"}
    )

    expect { hash[foo: "jane@doe.org", age: "20", admin: "1"] }.to raise_error(
      Dry::Types::MissingKeyError, /email/
    )
  end

  it "builds a strict hash" do
    ast = Dry::Types["nominal.hash"].schema(
      email: Dry::Types["nominal.string"]
    ).strict.to_ast

    hash = compiler.(ast)

    expect(hash).to be_a(Dry::Types::Hash)

    params = {email: "jane@doe.org", unexpected1: "wow", unexpected2: "wow"}
    expect {
      hash[params]
    }.to raise_error(Dry::Types::UnknownKeysError, /unexpected1, :unexpected2/)

    expect(hash[email: "jane@doe.org"]).to eql(email: "jane@doe.org")
  end

  it "builds a coercible hash" do
    ast = Dry::Types["nominal.hash"].schema(
      email: Dry::Types["nominal.string"],
      age?: Dry::Types["params.nil"] | Dry::Types["params.integer"],
      admin: Dry::Types["params.bool"]
    ).to_ast

    hash = compiler.(ast)

    expect(hash).to be_a(Dry::Types::Hash)

    result = hash[foo: "bar", email: "jane@doe.org", age: "20", admin: "1"]

    expect(result).to eql(email: "jane@doe.org", age: 20, admin: true)

    result = hash[foo: "bar", email: "jane@doe.org", age: "", admin: "1"]

    expect(result).to eql(email: "jane@doe.org", age: nil, admin: true)

    result = hash[foo: "bar", email: "jane@doe.org", admin: "1"]

    expect(result).to eql(email: "jane@doe.org", admin: true)
  end

  it "builds a coercible hash with symbolized keys" do
    ast = Dry::Types["nominal.hash"].schema(
      email?: Dry::Types["nominal.string"],
      age?: Dry::Types["params.integer"],
      admin?: Dry::Types["params.bool"]
    ).with_key_transform(&:to_sym).to_ast

    hash = compiler.(ast)

    expect(hash).to be_a(Dry::Types::Hash)

    expect(hash["foo" => "bar", "email" => "jane@doe.org", "age" => "20", "admin" => "1"]).to eql(
      email: "jane@doe.org", age: 20, admin: true
    )

    expect(hash["foo" => "bar", "age" => "20", "admin" => "1"]).to eql(
      age: 20, admin: true
    )
  end

  it "builds a hash with empty schema" do
    ast = Dry::Types["nominal.hash"].schema([]).to_ast

    hash = compiler.(ast)

    expect(hash[{}]).to eql({})
  end

  it "builds an array" do
    ast = Dry::Types["nominal.array"].of(
      Dry::Types["nominal.hash"].schema(
        email?: Dry::Types["nominal.string"],
        age: Dry::Types["params.integer"],
        admin: Dry::Types["params.bool"]
      ).with_key_transform(&:to_sym)
    ).to_ast

    arr = compiler.(ast)

    expect(arr).to be_a(Dry::Types::Array)

    input = [
      "foo" => "bar", "email" => "jane@doe.org", "age" => "20", "admin" => "1"
    ]

    expect(arr[input]).to eql([
      email: "jane@doe.org", age: 20, admin: true
    ])

    expect(arr[["foo" => "bar", "age" => "20", "admin" => "1"]]).to eql([
      age: 20, admin: true
    ])
  end

  it "builds a lax params array" do
    ast = Dry::Types["params.array"].lax.to_ast

    arr = compiler.(ast)

    expect(arr["oops"]).to eql("oops")
    expect(arr[""]).to eql([])
    expect(arr[%w[a b c]]).to eql(%w[a b c])
  end

  it "builds a lax params array with member" do
    ast = Dry::Types["params.array"].of(Dry::Types["coercible.integer"]).lax.to_ast

    arr = compiler.(ast)

    expect(arr["oops"]).to eql("oops")
    expect(arr[%w[1 2 3]]).to eql([1, 2, 3])
  end

  it "builds a safe params hash" do
    type = Dry::Types["params.hash"].schema(
      email: Dry::Types["nominal.string"],
      age: Dry::Types["params.integer"],
      admin: Dry::Types["params.bool"]
    ).with_key_transform(&:to_sym).lax

    ast = type.to_ast

    hash = compiler.(ast)

    expect(ast).to eql(hash.to_ast)

    expect(type).to eql(hash)

    expect(hash["oops"]).to eql("oops")

    expect(hash["foo" => "bar", "email" => "jane@doe.org", "age" => "20", "admin" => "1"]).to eql(
      email: "jane@doe.org", age: 20, admin: true
    )

    expect(hash["foo" => "bar", "age" => "20", "admin" => "1"]).to eql(
      age: 20, admin: true
    )
  end

  it "builds a schema-less form.hash" do
    ast = Dry::Types["params.hash"].schema([]).to_ast

    type = compiler.(ast)

    expect { type[nil] }.to raise_error(Dry::Types::CoercionError)
    expect(type[{}]).to eql({})
  end

  it "builds a params hash from a :params_hash node" do
    ast = [:params_hash, [[], {}]]

    type = compiler.(ast)

    expect(type.fn).to be(Dry::Types["params.hash"].fn)
  end

  it "builds a params array from a :params_array node" do
    ast = [:params_array, [[:nominal, [String, {}]], {}]]

    array = compiler.(ast)

    expect(array.member.primitive).to be(String)
  end

  it "builds a json hash from a :json_hash node" do
    ast = [:json_hash, [[], {}]]

    type = compiler.(ast)
    expected_result = Dry::Types["hash"].schema({})

    expect(type).to eql(expected_result)
  end

  it "builds a json array from a :json_array node" do
    ast = [:json_array, [[:nominal, [String, {}, {}]], {}]]

    array = compiler.(ast)

    expect(array.member.primitive).to be(String)
  end

  it "builds a strict type" do
    ast = Dry::Types["strict.string"].to_ast

    type = compiler.(ast)

    expect(type["hello"]).to eql("hello")
    expect(type.primitive).to be(String)
  end

  it "builds an and constrained" do
    ast = Dry::Types["strict.string"].constrained(size: 3..12).to_ast

    type = compiler.(ast)

    expect(type["hello"]).to eql("hello")
    expect(type.primitive).to be(String)
  end

  it "build or constrained" do
    ast = [
      :constrained, [[:nominal, [Integer, {}]],
                     [:or,
                      [
                        [:predicate, [:lt?, [[:num, 5], [:input, undefined]]]],
                        [:predicate, [:gt?, [[:num, 18], [:input, undefined]]]]
                      ]], {}]
    ]

    type = compiler.(ast)

    expect(type[4]).to eql(4)
    expect(type[19]).to eql(19)
    expect(type.primitive).to be(Integer)
  end

  it "builds a constructor with meta" do
    fn = -> v { v.to_s }

    ast = Dry::Types::Constructor.new(String, &fn).meta(foo: :bar).to_ast

    type = compiler.(ast)

    expect(type[:foo]).to eql("foo")

    expect(type.fn.fn).to be(fn)
    expect(type.primitive).to be(String)
    expect(type.meta).to eql(foo: :bar)
  end

  it "builds a enum" do
    enum = Dry::Types["strict.integer"].enum(1, 2, 3).meta(color: :red)

    ast = enum.to_ast

    type = compiler.(ast)

    expect(type).to eql(enum)
    expect(type.valid?(1)).to be(true)
    expect(type.valid?(4)).to be(false)
  end

  let(:any_ast) { [:any, {}] }

  it "builds the empty map" do
    ast = Dry::Types["nominal.hash"].map("any", "any").to_ast
    expect(ast).to eql([:map, [any_ast, any_ast, {}]])
    type = compiler.(ast)
    expect(type).to eql(Dry::Types::Map.new(Hash))
  end

  it "builds a complex map" do
    map = Dry::Types["hash"]
      .map("any", "any")
      .meta(abc: 123)
      .meta(foo: "bar")
      .with(key_type: Dry::Types["string"])
      .with(value_type: Dry::Types["integer"])

    ast = map.to_ast

    expect(ast).to eql([
      :map, [
        [:constrained,
         [[:nominal, [String, {}, {}]],
          [:predicate, [:type?, [[:type, String], [:input, undefined]]]]]],
        [:constrained,
         [[:nominal, [Integer, {}, {}]],
          [:predicate, [:type?, [[:type, Integer], [:input, undefined]]]]]],
        abc: 123, foo: "bar"
      ]
    ])

    type = compiler.(ast)

    expect(type).to eql(map)
    expect(type.meta).to eql(foo: "bar", abc: 123)
    expect(type.valid?("x" => 5)).to eql(true)
    expect(type.valid?(5 => "x")).to eql(false)
  end

  context "constructors" do
    example "simple constructor" do
      fn = -> v { v.to_s }

      ast = Dry::Types::Constructor.new(String, &fn).to_ast

      type = compiler.(ast)

      expect(type[:foo]).to eql("foo")

      expect(type.fn.fn).to be(fn)
      expect(type.primitive).to be(String)
    end

    example "built-in constructor type" do
      source = Dry::Types["params.integer"]
      ast = source.to_ast

      type = compiler.(ast)

      expect(type).to eql(source)
      expect(type.("1")).to eql(1)
    end

    example "wrapping constructor" do
      fn = lambda do |input, type, &block|
        300 + type.("#{input}0", &block)
      end

      source = Dry::Types["coercible.integer"].constructor(fn)

      ast = source.to_ast

      type = compiler.(ast)

      expect(type["123"]).to eql(1530)
      expect(type).to eql(source)
    end
  end

  context "composites" do
    let(:strict_nil_ast) do
      [:constrained,
       [[:nominal, [NilClass, {}]],
        [:predicate, [:type?, [[:type, NilClass], [:input, Undefined]]]]]]
    end

    let(:strict_integer_ast) do
      [:constrained,
       [[:nominal, [Integer, {}]],
        [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]]]]
    end

    let(:any_numeric_ast) do
      [:constrained, [[:any, {}], [:predicate, [:type?, [[:type, Numeric], [:input, Undefined]]]]]]
    end

    it 'builds a sum' do
      ast = [:sum, [strict_nil_ast, strict_integer_ast, {}]]
      type = compiler.(ast)
      expect(type).to eql(Dry::Types['integer'].optional)
    end

    it 'builds an implication' do
      ast = [:implication, [any_numeric_ast, strict_integer_ast, {}]]
      type = compiler.(ast)
      expect(type).to eql(Dry::Types['any'].constrained(type: Numeric) > Dry::Types['integer'])
    end

    it 'builds an intersection' do
      ast = [:intersection, [any_numeric_ast, strict_integer_ast, {}]]
      type = compiler.(ast)
      expect(type).to eql(Dry::Types['any'].constrained(type: Numeric) & Dry::Types['integer'])
    end
  end
end
