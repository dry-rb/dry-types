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

      def visit_type(node)
        type, args = node
        meth = :"visit_#{type.tr('.', '_')}"

        if respond_to?(meth)
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

      def visit_hash(node)
        constructor, schema = node
        registry['hash'].public_send(constructor, schema.map { |key| visit(key) }.reduce(:merge))
      end

      def visit_form_hash(node)
        constructor, schema = node
        registry['form.hash'].public_send(constructor, schema.map { |key| visit(key) }.reduce(:merge))
      end

      def visit_key(node)
        name, types = node
        { name => visit(types) }
      end
    end
  end
end
