# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dry::Types, '#to_ast' do
  let(:fn) { Kernel.method(:String) }

  let(:type_with_meta) { type.meta(key: :value) }

  context 'with a nominal' do
    subject(:type) { Dry::Types::Nominal.new(String) }

    specify do
      expect(type.to_ast).
        to eql([:nominal, [String, {}]])
    end

    specify 'with meta' do
      expect(type_with_meta.to_ast)
        .to eql([:nominal, [String, key: :value]])
    end

    specify 'without meta' do
      expect(type_with_meta.to_ast(meta: false))
        .to eql(type.to_ast)
    end
  end

  context 'with a sum' do
    subject(:type) { Dry::Types['nominal.string'] | Dry::Types['nominal.integer'] }

    specify do
      expect(type.to_ast).
        to eql([:sum, [[:nominal, [String, {}]], [:nominal, [Integer, {}]], {}]])
    end

    specify 'with meta' do
      expect(type_with_meta.to_ast).
        to eql([:sum, [
                  [:nominal, [String, {}]],
                  [:nominal, [Integer, {}]],
                  key: :value
                ]])
    end

    specify 'without meta' do
      type_with_meta = (
        Dry::Types['nominal.string'].meta(type: :str) | Dry::Types['nominal.integer'].meta(type: :int)
      ).meta(type: :sum)

      expect(type_with_meta.to_ast(meta: false)).to eql(type.to_ast)
    end
  end

  context 'with a constrained type' do
    subject(:type) { Dry::Types['strict.integer'] }

    specify do
      expect(type.to_ast).
        to eql([:constrained, [
                  [:nominal, [Integer, {}]],
                  [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]],
               ]])
    end

    specify 'with meta' do
      expect(type_with_meta.to_ast).
        to eql([:constrained, [
                  [:nominal, [Integer, key: :value]],
                  [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]]
                ]])
    end
  end

  context 'Hash' do
    subject(:type) { Dry::Types['nominal.hash'] }

    let(:type_transformation) { :itself.to_proc }
    let(:type_fn) { Dry::Types::FnContainer.register_name(type_transformation) }

    specify do
      expect(type.to_ast).
        to eql([:hash, [{}, {}]])
    end

    specify 'with type trasnformation' do
      expect(type.with_type_transform(type_transformation).to_ast).
        to eql([:hash, [{ type_transform_fn: type_fn }, {}]])
    end

    context 'schema' do
      subject(:type) { Dry::Types['nominal.hash'].schema(name: Dry::Types['nominal.string'], age: Dry::Types['nominal.integer']) }
      let(:keys_ast)  { type.keys.map(&:to_ast) }

      let(:key_transformation) { :to_sym.to_proc }

      let(:key_fn) { Dry::Types::FnContainer.register_name(key_transformation) }

      specify do
        expect(type.to_ast).
          to eql([:schema, [keys_ast, {}, {}]])
      end

      specify 'with meta' do
        expect(type_with_meta.to_ast).
          to eql([:schema, [keys_ast, {}, { key: :value }]])
      end

      specify 'with key transformation' do
        expect(type_with_meta.with_key_transform(key_transformation).to_ast).
          to eql([:schema, [keys_ast, { key_transform_fn: key_fn }, { key: :value }]])
      end
    end
  end

  context 'Enum' do
    subject(:type) { Dry::Types['string'].enum('draft', 'published', 'archived').meta(key: :value) }

    specify do
      expect(type.to_ast).
        to eql([
                 :enum,
                 [
                   [
                     :constrained,
                     [
                       [:nominal, [String, key: :value]],
                       [
                         :and,
                         [
                           [
                             :predicate,
                             [:type?, [[:type, String], [:input, Undefined]]]
                           ],
                           [
                             :predicate,
                             [:included_in?,
                              [[:list, ["draft", "published", "archived"]], [:input, Undefined]]]
                           ]
                         ]
                       ]
                     ]
                   ],
                   {"draft" => "draft", "published" => "published", "archived" => "archived"},
                 ]
               ])
    end
  end

  context 'Lax' do
    subject(:type) { Dry::Types['string'].constrained(min_size: 5).lax.meta(key: :value) }

    specify do
      expect(type.to_ast).to eql([:nominal, [String, key: :value]])
    end
  end

  context 'Constructor' do
    subject(:type) do
      Dry::Types::Constructor.new(Dry::Types['nominal.string'], fn: fn).meta(key: :value)
    end

    specify do
      expect(type.to_ast).
        to eql([:constructor, [[:nominal, [String, key: :value]], [:method, Kernel, :String]]])
    end
  end

  context 'Array' do
    subject(:type) { Dry::Types['nominal.array'] }

    specify do
      expect(type.to_ast).
        to eql([:nominal, [Array, {}]])
    end

    specify 'with meta' do
      expect(type_with_meta.to_ast).
        to eql([:nominal, [Array, key: :value]])
    end

    context 'Member' do
      subject(:type) do
        Dry::Types['nominal.array'].of(Dry::Types['nominal.string'])
      end

      specify do
        expect(type.to_ast).
          to eql([:array, [[:nominal, [String, {}]], {}]])
      end

      specify 'with meta' do
        expect(type_with_meta.to_ast).
          to eql([:array, [[:nominal, [String, {}]], key: :value]])
      end
    end

    context 'Member of structs' do
      let(:struct) do
        Test::Struct = Class.new { extend Dry::Types::Type }
      end

      subject(:type) do
        Dry::Types['nominal.array'].of(struct)
      end

      specify do
        expect(type.to_ast).to eql([:array, [struct, {}]])
      end
    end
  end
end
