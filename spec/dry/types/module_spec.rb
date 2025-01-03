# frozen_string_literal: true

require "dry/struct"

RSpec.describe Dry::Types::Module do
  let(:registry) { Dry::Types.container }

  context "builder methods" do
    subject(:mod) { Dry::Types() }

    describe ".Array" do
      it "builds an array type" do
        expect(mod.Array(mod::Strict::Integer)).to eql(
          Dry::Types["strict.array<strict.integer>"]
        )
      end
    end

    describe ".Instance" do
      it "builds a nominal of a class instance" do
        foo_type = Class.new

        expect(mod.Instance(foo_type)).to eql(
          Dry::Types::Nominal.new(foo_type).constrained(type: foo_type)
        )
      end
    end

    describe ".Value" do
      it "builds a nominal of a single value" do
        expect(mod.Value({})).to eql(
          Dry::Types::Hash.new(Hash).constrained(eql: {})
        )
      end
    end

    describe ".Constant" do
      it "builds a nominal of a constant" do
        obj = Object.new

        expect(mod.Constant(obj)).to eql(
          Dry::Types::Nominal.new(Object).constrained(is: obj)
        )
      end
    end

    describe ".Hash" do
      it "builds a hash schema" do
        expect(mod.Hash(age: Dry::Types["strict.integer"])).to eql(
          Dry::Types["strict.hash"].schema(age: Dry::Types["strict.integer"])
        )
      end
    end

    describe ".Map" do
      it "builds a map type" do
        expected = Dry::Types::Map.new(Hash, key_type: Dry::Types["strict.integer"])
        expect(mod.Map(mod::Integer, "any")).to eql(expected)
      end
    end

    describe ".Constructor" do
      it "builds a constructor type" do
        to_s = :to_s.to_proc

        expect(mod.Constructor(String, &to_s)).to eql(
          Dry::Types::Nominal.new(String).constructor(to_s)
        )

        expect(mod.Constructor(String, to_s)).to eql(
          Dry::Types::Nominal.new(String).constructor(to_s)
        )
      end

      it "uses .new method by default" do
        type = mod.Constructor(String)

        expect(type["foo"]).to eql("foo")
        expect { type[1] }.to raise_error(Dry::Types::CoercionError)
      end

      it "uses Types::Array for arrays" do
        array = method(:Array)
        expect(mod.Constructor(Array, array)).to eql(
          Dry::Types["nominal.array"].constructor(array)
        )
      end

      it "uses Types::Hash for hashes" do
        hash = method(:Hash)
        expect(mod.Constructor(Hash, hash)).to eql(
          Dry::Types["nominal.hash"].constructor(hash)
        )
      end

      it "works with a type" do
        to_s = :to_s.to_proc

        expect(mod.Constructor(Dry::Types["nominal.string"], &to_s)).to eql(
          mod.Constructor(String, &to_s)
        )
      end

      context "with struct" do
        let(:user_struct) { Dry.Struct(name: "string") }

        it "returns struct back if no constructor block provided" do
          expect(mod.Constructor(user_struct)).to be(user_struct)
        end
      end
    end

    describe ".Nominal" do
      it "builds a nominal type" do
        expect(mod.Nominal(String)).to eql(Dry::Types::Nominal.new(String))
      end
    end

    it "defines methods when included" do
      expect(Module.new.tap { |m| m.include mod }.Nominal(String)).to eql(
        mod.Nominal(String)
      )
    end

    it "uses Types::Array for array types" do
      expect(mod.Nominal(Array)).to be_a(Dry::Types::Array)
    end

    it "uses Types::Hash for hash types" do
      expect(mod.Nominal(Hash)).to be_a(Dry::Types::Hash)
    end

    describe ".Strict" do
      it "is an alias for Instance" do
        foo_type = Class.new

        expect(mod.Strict(foo_type)).to eql(mod.Instance(foo_type))
        expect(mod.Strict(Integer)).to eql(mod::Strict::Integer)
      end
    end

    describe ".Interface" do
      it "builds a constrained nominal type of any responding to methods" do
        expect(mod.Interface(:new, :method)).to eql(
          Dry::Types::Any.constrained(respond_to: :new).constrained(respond_to: :method)
        )
      end
    end

    describe "JSON" do
      it "defines json types" do
        expect(mod::JSON::Decimal).to be(Dry::Types["json.decimal"])
      end
    end
  end

  context "parameters" do
    subject(:mod) { Dry::Types::Module.new(registry, *args, **kwargs) }

    let(:args) { [] }

    let(:kwargs) { {} }

    context "no options" do
      it "contains all types by default" do
        expect(mod.constants.to_set).to(
          be > %i[Strict Coercible Optional JSON Params Integer].to_set
        )
      end
    end

    %i[strict coercible params json nominal].each do |ns|
      constant = Dry::Types::Inflector.camelize(ns.to_s).to_sym

      context ns.to_s do
        let(:args) { [ns] }

        it "includes only #{ns} types" do
          constants = mod.constants(false)
          expect(constants).to eql([constant])
          expect(mod.const_get(constant)::Decimal).to be(Dry::Types["#{ns}.decimal"])
        end
      end
    end

    context "multiple namespaces" do
      let(:args) { %i[strict nominal] }

      it "adds only two constants" do
        constants = mod.constants(false)
        expect(constants.sort).to eql(%i[Nominal Strict])
      end
    end

    context "default types" do
      context "several namespaces with default" do
        let(:args) { [:nominal] }

        let(:kwargs) { {default: :strict} }

        it "adds strict types as default" do
          expect(mod::Integer).to be(Dry::Types["integer"])
          expect(mod::Nominal::Integer).to be(Dry::Types["nominal.integer"])
          expect { mod::Params }.to raise_error(NameError)
        end
      end

      context "any" do
        context "no options" do
          it "is available by default" do
            expect(mod::Any).to be(registry["any"])
          end
        end

        context "strict" do
          let(:kwargs) { {default: :strict} }

          it "is available" do
            expect(mod::Any).to be(registry["any"])
          end
        end
      end

      context "bool" do
        context "no options" do
          it "is available by default" do
            expect(mod::Bool).to be(registry["strict.bool"])
          end
        end
      end

      context "without namespaces" do
        let(:kwargs) { {default: :strict} }

        it "adds all namespaces wiht strict types as default" do
          expect(mod::Integer).to be(Dry::Types["strict.integer"])
          expect(mod::Nominal::Integer).to be(Dry::Types["nominal.integer"])
        end
      end

      context "disabling defaults" do
        let(:kwargs) { {default: false} }

        it "doesn't add nominal types as a default" do
          expect(mod::Nominal::Integer).to be(Dry::Types["nominal.integer"])
          expect { mod::Integer }.to raise_error(NameError)
        end
      end

      it "rejects invalid options" do
        expect {
          described_class.new(registry, default: :something)
        }.to raise_error(ArgumentError, /:something/)
      end

      context "optional defaults" do
        let(:kwargs) { {default: :optional} }

        it "adds optional types as defaults" do
          expect(mod::Strict::Integer).to be_optional
          expect(mod::Coercible::Integer).to be_optional
        end
      end

      example "default types in optional ns are strict" do
        expect(mod::Optional::String).to eql(mod::String.optional)
      end
    end

    context "aliases" do
      subject(:mod) { Dry::Types(strict: :Strong) }

      it "uses custom names for modules" do
        expect(mod.constants(false)).to eql([:Strong])
        expect(mod::Strong::Integer).to be(Dry::Types["strict.integer"])
      end
    end
  end

  it "prevents accidental import of wrong module" do
    expect { Module.new { include Dry::Types } }.to raise_error(RuntimeError)
  end
end
