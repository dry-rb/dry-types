require 'bigdecimal'
require 'date'
require 'set'

require 'inflecto'
require 'thread_safe'

require 'dry-container'
require 'dry-equalizer'

require 'dry/types/version'
require 'dry/types/container'
require 'dry/types/type'
require 'dry/types/struct'
require 'dry/types/value'

module Dry
  module Types
    extend Dry::Configurable

    setting :namespace, self

    class SchemaError < TypeError
      def initialize(key, value)
        super("#{value.inspect} (#{value.class}) has invalid type for :#{key}")
      end
    end

    class SchemaKeyError < KeyError
      def initialize(key)
        super(":#{key} is missing in Hash input")
      end
    end

    StructError = Class.new(TypeError)
    ConstraintError = Class.new(TypeError)

    TYPE_SPEC_REGEX = %r[(.+)<(.+)>].freeze

    def self.finalize
      define_constants(config.namespace, container._container.keys)
    end

    def self.container
      @container ||= Container.new
    end

    def self.register(name, type = nil, &block)
      container.register(name, type || block.call)
    end

    def self.register_class(klass)
      container.register(
        Inflecto.underscore(klass).gsub('/', '.'),
        Type.new(klass.method(:new), primitive: klass)
      )
    end

    def self.[](name)
      type_map.fetch_or_store(name) do
        type =
          case name
          when String
            result = name.match(TYPE_SPEC_REGEX)

            type =
              if result
                type_id, member_id = result[1..2]
                container[type_id].member(self[member_id])
              else
                container[name]
              end
          when Class
            self[identifier(name)]
          end

        type
      end
    end

    def self.define_constants(namespace, identifiers)
      names = identifiers.map do |id|
        parts = id.split('.')
        [Inflecto.camelize(parts.pop), parts.map(&Inflecto.method(:camelize))]
      end

      names.map do |(klass, parts)|
        mod = parts.reduce(namespace) do |a, e|
          a.constants.include?(e.to_sym) ? a.const_get(e) : a.const_set(e, Module.new)
        end

        mod.const_set(klass, self[identifier((parts + [klass]).join('::'))])
      end
    end

    def self.identifier(klass)
      Inflecto.underscore(klass).gsub('/', '.')
    end

    def self.type_map
      @type_map ||= ThreadSafe::Cache.new
    end
  end
end

require 'dry/types/types' # load built-in types
