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
        type, meta, ast = node
        send(:"visit_#{ type }", ast || meta, meta)
      end

      def visit_constructor(node, meta)
        definition, fn_register_name = node
        fn = Dry::Types::FnContainer[fn_register_name]
        primitive = visit(definition)
        Types::Constructor.new(primitive, &fn)
      end

      def visit_safe(node, meta)
        Types::Safe.new(call(node))
      end

      def visit_definition(node, meta)
        if registry.registered?(node)
          registry[node].meta(meta)
        else
          Definition.new(node, meta: meta)
        end
      end

      def visit_sum(node, meta)
        node.map { |type| visit(type) }.reduce(:|).meta(meta)
      end

      def visit_array(node, meta)
        registry['array'].member(call(node)).meta(meta)
      end

      def visit_hash(node, meta)
        constructor, schema = node
        merge_with('hash', constructor, schema)
      end

      def visit_member(node, _)
        name, type = node
        { name => visit(type) }
      end

      def merge_with(hash_id, constructor, schema)
        registry[hash_id].__send__(
          constructor, schema.map { |key| visit(key) }.reduce({}, :merge)
        )
      end
    end
  end
end
