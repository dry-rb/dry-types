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
        primitive, fn = node
        Types::Constructor.new(primitive, &fn)
      end

      def visit_type(node)
        type, args = node
        meth = :"visit_#{type.tr('.', '_')}"

        if respond_to?(meth) && args
          send(meth, args)
        else
          registry[type]
        end
      end

      def visit_sum(node)
        node.map { |type| visit(type) }.reduce(:|)
      end

      def visit_array(node)
        registry['array'].member(call(node))
      end

      def visit_form_array(node)
        registry['form.array'].member(call(node))
      end

      def visit_json_array(node)
        registry['json.array'].member(call(node))
      end

      def visit_hash(node)
        constructor, schema = node
        merge_with('hash', constructor, schema)
      end

      def visit_form_hash(node)
        if node
          constructor, schema = node
          merge_with('form.hash', constructor, schema)
        else
          registry['form.hash']
        end
      end

      def visit_json_hash(node)
        if node
          constructor, schema = node
          merge_with('json.hash', constructor, schema)
        else
          registry['json.hash']
        end
      end

      def visit_key(node)
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
