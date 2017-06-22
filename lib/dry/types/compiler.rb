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

      def visit_constructor(node)
        definition, fn_register_name, meta = node
        fn = Dry::Types::FnContainer[fn_register_name]
        primitive = visit(definition)
        Types::Constructor.new(primitive, &fn)
      end

      def visit_safe(node)
        ast, meta = node
        Types::Safe.new(call(ast), meta: meta)
      end

      def visit_definition(node)
        type, meta = node

        if registry.registered?(type)
          registry[type].meta(meta)
        else
          Definition.new(type, meta: meta)
        end
      end

      def visit_sum(node)
        *types, meta = node
        types.map { |type| visit(type) }.reduce(:|).meta(meta)
      end

      def visit_array(node)
        member, meta = node
        registry['array'].member(call(member)).meta(meta)
      end

      def visit_hash(node)
        constructor, schema, meta = node
        merge_with('hash', constructor, schema).meta(meta)
      end

      def visit_json_array(node)
        registry['json.array'].member(call(node))
      end

      def visit_json_hash(node)
        if node
          constructor, schema = node
          merge_with('json.hash', constructor, schema)
        else
          registry['json.hash']
        end
      end

      def visit_form_hash(node)
        if node
          constructor, schema, meta = node
          merge_with('form.hash', constructor, schema).meta(meta)
        else
          registry['form.hash']
        end
      end

      def visit_form_array(node)
        registry['form.array'].member(call(node))
      end

      def visit_member(node)
        name, type = node
        { name => visit(type) }
      end

      def merge_with(hash_id, constructor, schema)
        registry[hash_id].__send__(
          constructor, schema.map { |key| visit(key) }.reduce({}, :update)
        )
      end
    end
  end
end
