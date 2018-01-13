require 'spec_helper'

RSpec.describe Dry::Types, '#to_ast' do
  let(:fn) { Kernel.method(:String) }

  let(:type_with_meta) { type.meta(key: :value) }

  context 'with a definition' do
    subject(:type) { Dry::Types::Definition.new(String) }

    specify do
      expect(type.to_ast).
        to eql([:definition, [String, {}]])
    end

    specify 'with meta' do
      expect(type_with_meta.to_ast)
        .to eql([:definition, [String, key: :value]])
    end

    specify 'without meta' do
      expect(type_with_meta.to_ast(meta: false))
        .to eql(type.to_ast)
    end
  end

  context 'with a sum' do
    subject(:type) { Dry::Types['string'] | Dry::Types['integer'] }

    specify do
      expect(type.to_ast).
        to eql([:sum, [[:definition, [String, {}]], [:definition, [Integer, {}]], {}]])
    end

    specify 'with meta' do
      expect(type_with_meta.to_ast).
        to eql([:sum, [
                  [:definition, [String, {}]],
                  [:definition, [Integer, {}]],
                  key: :value
                ]])
    end

    specify 'without meta' do
      type_with_meta = (
        Dry::Types['string'].meta(type: :str) | Dry::Types['integer'].meta(type: :int)
      ).meta(type: :sum)

      expect(type_with_meta.to_ast(meta: false)).to eql(type.to_ast)
    end
  end

  context 'with a constrained type' do
    subject(:type) { Dry::Types['strict.integer'] }

    specify do
      expect(type.to_ast).
        to eql([:constrained, [
                  [:definition, [Integer, {}]],
                  [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]],
                  {}
               ]])
    end

    specify 'with meta' do
      expect(type_with_meta.to_ast).
        to eql([:constrained, [
                  [:definition, [Integer, {}]],
                  [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]],
                  key: :value
                ]])
    end
  end

  context 'Hash' do
    subject(:type) { Dry::Types['hash'] }

    specify do
      expect(type.to_ast).
        to eql([:definition, [Hash, {}]])
    end

    context 'schema' do
      subject(:type) { Dry::Types['hash'].schema(name: Dry::Types['string'], age: Dry::Types['integer']) }
      let(:member_types_ast)  { type.member_types.map { |name, member| [:member, [name, member.to_ast]] } }

      specify do
        expect(type.to_ast).
          to eql([:hash_schema, [member_types_ast, {}]])
      end

      specify 'with meta' do
        expect(type_with_meta.to_ast).
          to eql([:hash_schema, [member_types_ast, key: :value]])
      end
    end
  end

  context 'lagacy Hash schemas' do
    subject(:type) { Dry::Types['hash'] }
    let(:members) { { name: Dry::Types['string'], age: Dry::Types['integer'] } }

    specify do
      expect(type.to_ast).
        to eql([:definition, [Hash, {}]])
    end

    %i(schema weak permissive strict strict_with_defaults symbolized).each do |schema|
      meta = {}
      meta[:permissive] = true if %i(schema weak symbolized permissive).include?(schema)
      meta[:key_transform_fn] = Dry::Types::Hash::Schema::SYMBOLIZE_KEY if schema == :symbolized

      context "#{schema.capitalize}" do
        subject(:type) do
          if schema == :schema
            Dry::Types['hash'].schema(members, :schema )
          else
            Dry::Types['hash'].send(schema, members)
          end
        end
        let(:member_types_ast)  { type.member_types.map { |name, member| [:member, [name, member.to_ast]] } }

        specify do
          expect(type.to_ast).
            to eql([:hash_schema, [member_types_ast, meta]])
        end

        specify 'with meta' do
          expect(type_with_meta.to_ast).
            to eql([:hash_schema, [member_types_ast, key: :value, **meta]])
        end
      end
    end
  end

  context 'Enum' do
    subject(:type) { Dry::Types['strict.string'].enum('draft', 'published', 'archived').meta(key: :value) }

    specify do
      expect(type.to_ast).
        to eql([
                 :enum,
                 [
                   [
                     :constrained,
                     [
                       [:definition, [String, {}]],
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
                       ],
                       {}
                     ]
                   ],
                   key: :value
                 ]
               ])
    end
  end

  context 'Safe' do
    subject(:type) { Dry::Types['string'].constrained(min_size: 5).safe.meta(key: :value) }

    specify do
      expect(type.to_ast).
        to eql([
                 :safe,
                 [
                   [
                     :constrained,
                     [
                       [:definition, [String, {}]],
                       [:predicate, [:min_size?, [[:num, 5], [:input, Undefined]]]],
                       key: :value
                     ]
                   ],
                   {}
                 ]
               ])
    end
  end

  context 'Constructor' do
    subject(:type) do
      Dry::Types::Constructor.new(Dry::Types['string'], fn: fn).meta(key: :value)
    end

    specify do
      expect(type.to_ast).
        to eql([:constructor, [[:definition, [String, {}]], "fn_#{fn.object_id}", key: :value]])
    end
  end

  context 'Array' do
    subject(:type) { Dry::Types['array'] }

    specify do
      expect(type.to_ast).
        to eql([:definition, [Array, {}]])
    end

    specify 'with meta' do
      expect(type_with_meta.to_ast).
        to eql([:definition, [Array, key: :value]])
    end

    context 'Member' do
      subject(:type) do
        Dry::Types['array'].of(Dry::Types['string'])
      end

      specify do
        expect(type.to_ast).
          to eql([:array, [[:definition, [String, {}]], {}]])
      end

      specify 'with meta' do
        expect(type_with_meta.to_ast).
          to eql([:array, [[:definition, [String, {}]], key: :value]])
      end
    end
  end
end
