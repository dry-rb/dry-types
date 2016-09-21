require 'bigdecimal'
require 'date'
require 'set'

require 'inflecto'
require 'concurrent'

require 'dry-container'
require 'dry-equalizer'
require 'dry/core/extensions'

require 'dry/types/version'
require 'dry/types/container'
require 'dry/types/definition'
require 'dry/types/constructor'

require 'dry/types/errors'

module Dry
  module Types
    extend Dry::Configurable
    extend Dry::Core::Extensions

    setting :namespace, self

    TYPE_SPEC_REGEX = %r[(.+)<(.+)>].freeze

    def self.module
      namespace = Module.new
      define_constants(namespace, type_keys)
      namespace
    end

    def self.finalize
      warn 'Dry::Types.finalize and configuring namespace is deprecated. Just'\
       ' do `include Dry::Types.module` in places where you want to have access'\
       ' to built-in types'

      define_constants(config.namespace, type_keys)
    end

    def self.container
      @container ||= Container.new
    end

    def self.register(name, type = nil, &block)
      container.register(name, type || block.call)
    end

    def self.register_class(klass, meth = :new)
      type = Definition.new(klass).constructor(klass.method(meth))
      container.register(identifier(klass), type)
    end

    def self.[](name)
      type_map.fetch_or_store(name) do
        case name
        when String
          result = name.match(TYPE_SPEC_REGEX)

          if result
            type_id, member_id = result[1..2]
            container[type_id].member(self[member_id])
          else
            container[name]
          end
        when Class
          type_name = identifier(name)

          if container.key?(type_name)
            self[type_name]
          else
            name
          end
        end
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
      Inflecto.underscore(klass).tr('/', '.')
    end

    def self.type_map
      @type_map ||= Concurrent::Map.new
    end

    def self.type_keys
      container._container.keys
    end
  end
end

require 'dry/types/core' # load built-in types
require 'dry/types/extensions'
