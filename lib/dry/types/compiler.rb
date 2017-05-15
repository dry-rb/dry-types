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

      def visit(node, *args)
        send(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_constructor(node)
        definition, fn_register_name = node
        fn = Dry::Types::FnContainer[fn_register_name]
        primitive = visit(definition)
        Types::Constructor.new(primitive, &fn)
      end

      def visit_safe(node)
        Types::Safe.new(call(node))
      end

      def visit_definition(node)
        primitive = node

        if registry.registered?(primitive)
          registry[primitive]
        else
          Definition.new(primitive)
        end
      end

      def visit_sum(node)
        node.map { |type| visit(type) }.reduce(:|)
      end

      def visit_array(node)
        registry['array'].member(call(node))
      end

      def visit_hash(node)
        constructor, schema = node
        merge_with('hash', constructor, schema)
      end

      def visit_member(node)
        name, types = node
        { name => visit(types) }
      end

      def merge_with(hash_id, constructor, schema)
        registry[hash_id].__send__(
          constructor, schema.map { |key| visit(key) }.reduce({}, :merge)
        )
      end
    end
  end
end
