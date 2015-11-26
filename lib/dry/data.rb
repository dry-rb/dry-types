require 'bigdecimal'
require 'date'
require 'set'

require 'dry-container'
require 'inflecto'

require 'dry/data/version'
require 'dry/data/container'
require 'dry/data/type'
require 'dry/data/struct'
require 'dry/data/dsl'

module Dry
  module Data
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

    TYPE_SPEC_REGEX = %r[(.+)<(.+)>].freeze

    def self.container
      @container ||= Container.new
    end

    def self.register(name, type = nil, &block)
      container.register(name, type || block.call)
    end

    def self.register_class(klass)
      container.register(
        Inflecto.underscore(klass).gsub('/', '.'),
        Type.new(klass.method(:new), klass)
      )
    end

    def self.[](name)
      type_map.fetch(name) do
        result = name.match(TYPE_SPEC_REGEX)

        type =
          if result
            type_id, member_id = result[1..2]
            container[type_id].member(self[member_id])
          else
            container[name]
          end

        type_map[name] = type
      end
    end

    def self.type(*args, &block)
      dsl = DSL.new(container)
      block ? yield(dsl) : registry[args.first]
    end

    def self.type_map
      @type_map ||= {}
    end
  end
end

require 'dry/data/types' # load built-in types
