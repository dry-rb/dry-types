require 'spec_helper'

RSpec.describe Dry::Types, '#to_ast' do
  let(:fn) { Kernel.method(:String) }

  context 'with a definition' do
    subject(:type) { Dry::Types::Definition.new(String) }

    specify do
      expect(type.to_ast).
        to eql([:definition, [:primitive, String]])
    end
  end

  context 'with a sum' do
    subject(:type) { Dry::Types['string'] | Dry::Types['int'] }

    specify do
      expect(type.to_ast).
        to eql([:sum, [
                  [:definition, [:primitive, String]],
                  [:definition, [:primitive, Integer]]
                ]])
    end
  end

  context 'with a constrained type' do
    subject(:type) { Dry::Types['strict.int'] }

    specify do
      expect(type.to_ast).
        to eql([:constrained, [
                  [:definition, [:primitive, Integer]],
                  [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]]
               ]])
    end
  end

  context 'Hash' do
    subject(:type) { Dry::Types['hash'] }

    specify do
      expect(type.to_ast).
        to eql([:definition, [:primitive, Hash]])
    end

    %i(schema weak permissive strict strict_with_defaults symbolized).each do |schema|
      context "#{schema.capitalize}" do
        subject(:type) { Dry::Types['hash'].send(schema, { name: Dry::Types['string'], age: Dry::Types['int'] }) }
        let(:member_types_ast)  { type.member_types.map { |name, member| [:member, [name, member.to_ast]] } }

        specify do
          expect(type.to_ast).
            to eql([:hash, [schema, [ member_types_ast ]]])
        end
      end
    end
  end

  context 'Enum' do
    subject(:type) { Dry::Types['strict.string'].enum('draft', 'published', 'archived') }

    specify do
      expect(type.to_ast).
        to eql([
                 :enum,
                 [
                   [
                     :constrained,
                     [
                       [
                         :definition, [:primitive, String]
                       ],
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
                   ]
                 ]
               ])
    end
  end

  context 'Safe' do
    subject(:type) { Dry::Types['string'].constrained(min_size: 5).safe }

    specify do
      expect(type.to_ast).
        to eql([
                :safe,
                [
                  [
                    :constrained,
                    [
                      [
                        :definition, [:primitive, String]
                      ],
                      [
                        :predicate, [:min_size?, [[:num, 5], [:input, Undefined]]]
                      ]
                    ]
                  ]
                ]
              ])
    end
  end

  context 'Constructor' do
    subject(:type) do
      Dry::Types::Constructor.new(Dry::Types['string'], fn: fn)
    end

    specify do
      expect(type.to_ast).
        to eql([:constructor, [[:definition, [:primitive, String]], "fn_#{fn.object_id}" ]])
    end
  end

  context 'Array' do
    subject(:type) { Dry::Types['array'] }

    specify do
      expect(type.to_ast).
        to eql([:definition, [:primitive, Array]])
    end

    context 'Member' do
      subject(:type) do
        Dry::Types['array'].member(Dry::Types['string'])
      end

      specify do
        expect(type.to_ast).
          to eql([:array, [:definition, [:primitive, String]]])
      end
    end
  end
end
