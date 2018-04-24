module Dry
  module Types
    class Compiler
      attr_reader :registry

      def initialize(registry)
        @registry = registry
      end

      def call(ast)
        visit(ast)
      end

      def visit(node)
        type, body = node
        send(:"visit_#{ type }", body)
      end

      def visit_constrained(node)
        definition, rule, meta = node
        Types::Constrained.new(visit(definition), rule: visit_rule(rule)).meta(meta)
      end

      def visit_constructor(node)
        definition, fn_register_name, meta = node
        fn = Dry::Types::FnContainer[fn_register_name]
        primitive = visit(definition)
        Types::Constructor.new(primitive, meta: meta, fn: fn)
      end

      def visit_safe(node)
        ast, meta = node
        Types::Safe.new(visit(ast), meta: meta)
      end

      def visit_definition(node)
        type, meta = node

        if registry.registered?(type)
          registry[type].meta(meta)
        else
          Definition.new(type, meta: meta)
        end
      end

      def visit_rule(node)
        Dry::Types.rule_compiler.([node])[0]
      end

      def visit_sum(node)
        *types, meta = node
        types.map { |type| visit(type) }.reduce(:|).meta(meta)
      end

      def visit_array(node)
        member, meta = node
        member = member.is_a?(Class) ? member : visit(member)
        registry['array'].of(member).meta(meta)
      end

      def visit_hash(node)
        constructor, schema, meta = node
        merge_with('hash', constructor, schema).meta(meta)
      end

      def visit_hash_schema(node)
        schema, meta = node
        merge_with_schema('hash', schema).meta(meta)
      end

      def visit_json_hash(node)
        schema, meta = node
        merge_with('json.hash', :symbolized, schema).meta(meta)
      end

      def visit_json_array(node)
        member, meta = node
        registry['json.array'].of(visit(member)).meta(meta)
      end

      def visit_params_hash(node)
        schema, meta = node
        merge_with('params.hash', :symbolized, schema).meta(meta)
      end

      def visit_params_array(node)
        member, meta = node
        registry['params.array'].of(visit(member)).meta(meta)
      end

      def visit_member(node)
        name, type = node
        { name => visit(type) }
      end

      def visit_enum(node)
        type, mapping, meta = node
        Enum.new(visit(type), mapping: mapping, meta: meta)
      end

      def visit_map(node)
        key_type, value_type, meta = node
        registry['hash'].map(visit(key_type), visit(value_type)).meta(meta)
      end

      def merge_with(hash_id, constructor, schema)
        registry[hash_id].schema(
          schema.map { |key| visit(key) }.reduce({}, :update),
          constructor
        )
      end

      def merge_with_schema(hash_id, schema)
        registry[hash_id].instantiate(
          schema.map { |key| visit(key) }.reduce({}, :update)
        )
      end
    end
  end
end
