require 'dry/types/builder_methods'

module Dry
  module Types
    class Module < ::Module
      def initialize(registry, *args)
        @registry = registry
        constants = type_constants(*args)
        define_constants(constants)
        extend(BuilderMethods)
      end

      # @param [Module] namespace
      # @param [<String>] identifiers
      # @return [<Definition>]
      def define_constants(constants, mod = self)
        constants.each do |name, value|
          case value
          when ::Hash
            if mod.const_defined?(name, false)
              define_constants(value, mod.const_get(name, false))
            else
              m = ::Module.new
              mod.const_set(name, m)
              define_constants(value, m)
            end
          else
            mod.const_set(name, value)
          end
        end
      end

      # @api private
      def type_constants(*namespaces, default: Undefined, **aliases)
        if namespaces.empty? && aliases.empty?
          registry_tree
        else
          tree = registry_tree(only_namespaces: true)
          modules = namespaces.map { |n| Inflector.camelize(n).to_sym }
          default_ns = Inflector.camelize(default).to_sym unless Undefined.equal?(default)

          tree.flat_map { |key, value|
            if modules.include?(key)
              [[key, value]]
            elsif key == default_ns
              value.to_a
            else
              EMPTY_ARRAY
            end
          }.compact.to_h
        end
      end

      # @api private
      def registry_tree(only_namespaces: false)
        @registry_tree ||= @registry.keys.each_with_object({}) do |key, tree|
          type = @registry[key]
          *modules, const_name = key.split('.').map { |part|
            Inflector.camelize(part).to_sym
          }

          subtree = modules.reduce(tree) do |branch, name|
            branch[name] ||= {}
          end

          subtree[const_name] = type if !only_namespaces || !modules.empty?
        end
      end
    end
  end
end
