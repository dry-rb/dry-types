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
        nominal, rule, meta = node
        Types::Constrained.new(visit(nominal), rule: visit_rule(rule)).meta(meta)
      end

      def visit_constructor(node)
        nominal, fn_register_name, meta = node
        fn = Dry::Types::FnContainer[fn_register_name]
        primitive = visit(nominal)
        Types::Constructor.new(primitive, meta: meta, fn: fn)
      end

      def visit_safe(node)
        ast, meta = node
        Types::Safe.new(visit(ast), meta: meta)
      end

      def visit_nominal(node)
        type, meta = node
        nominal_name = "nominal.#{ Types.identifier(type) }"

        if registry.registered?(nominal_name)
          registry[nominal_name].meta(meta)
        else
          Nominal.new(type, meta: meta)
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
        registry['nominal.array'].of(member).meta(meta)
      end

      def visit_hash(node)
        opts, meta = node
        registry['nominal.hash'].with(opts.merge(meta: meta))
      end

      def visit_schema(node)
        keys, options, meta = node
        registry['nominal.hash'].schema(keys.map { |key| visit(key) }).with(options.merge(meta: meta))
      end

      def visit_json_hash(node)
        keys, meta = node
        registry['json.hash'].schema(keys.map { |key| visit(key) }, meta)
      end

      def visit_json_array(node)
        member, meta = node
        registry['json.array'].of(visit(member)).meta(meta)
      end

      def visit_params_hash(node)
        keys, meta = node
        registry['params.hash'].schema(keys.map { |key| visit(key) }, meta)
      end

      def visit_params_array(node)
        member, meta = node
        registry['params.array'].of(visit(member)).meta(meta)
      end

      def visit_key(node)
        name, required, type = node
        Schema::Key.new(visit(type), name, required: required)
      end

      def visit_enum(node)
        type, mapping, meta = node
        Enum.new(visit(type), mapping: mapping, meta: meta)
      end

      def visit_map(node)
        key_type, value_type, meta = node
        registry['nominal.hash'].map(visit(key_type), visit(value_type)).meta(meta)
      end

      def visit_any(meta)
        registry['any'].meta(meta)
      end
    end
  end
end
