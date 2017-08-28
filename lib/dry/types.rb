require 'bigdecimal'
require 'date'
require 'set'

require 'inflecto'
require 'concurrent'

require 'dry-container'
require 'dry-equalizer'
require 'dry/core/extensions'
require 'dry/core/constants'

require 'dry/types/version'
require 'dry/types/container'
require 'dry/types/type'
require 'dry/types/definition'
require 'dry/types/constructor'
require 'dry/types/fn_container'
require 'dry/types/builder_methods'

require 'dry/types/errors'

module Dry
  module Types
    extend Dry::Configurable
    extend Dry::Core::Extensions
    include Dry::Core::Constants

    # @!attribute [r] namespace
    #   @return [Container{String => Definition}]
    setting :namespace, self

    TYPE_SPEC_REGEX = %r[(.+)<(.+)>].freeze

    # @return [Module]
    def self.module
      namespace = Module.new
      define_constants(namespace, type_keys)
      namespace.extend(BuilderMethods)
      namespace
    end

    # @deprecated Include {Dry::Types.module} instead
    def self.finalize
      warn 'Dry::Types.finalize and configuring namespace is deprecated. Just'\
       ' do `include Dry::Types.module` in places where you want to have access'\
       ' to built-in types'

      define_constants(config.namespace, type_keys)
    end

    # @return [Container{String => Definition}]
    def self.container
      @container ||= Container.new
    end

    # @api private
    def self.registered?(class_or_identifier)
      container.key?(identifier(class_or_identifier))
    end

    # @param [String] name
    # @param [Type] type
    # @param [#call,nil] block
    # @return [Container{String => Definition}]
    def self.register(name, type = nil, &block)
      container.register(name, type || block.call)
    end

    # Registers given +klass+ in {#container} using +meth+ constructor
    # @param [Class] klass
    # @param [Symbol] meth
    # @return [Container{String => Definition}]
    def self.register_class(klass, meth = :new)
      type = Definition.new(klass).constructor(klass.method(meth))
      container.register(identifier(klass), type)
    end

    # @param [String,Class] name
    # @return [Type,Class]
    def self.[](name)
      type_map.fetch_or_store(name) do
        case name
        when String
          result = name.match(TYPE_SPEC_REGEX)

          if result
            type_id, member_id = result[1..2]
            container[type_id].of(self[member_id])
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

    # @param [Module] namespace
    # @param [<String>] identifiers
    # @return [<Definition>]
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

    # @param [#to_s] klass
    # @return [String]
    def self.identifier(klass)
      Inflecto.underscore(klass).tr('/', '.')
    end

    # @return [Concurrent::Map]
    def self.type_map
      @type_map ||= Concurrent::Map.new
    end

    # List of type keys defined in {Dry::Types.container}
    # @return [<String>]
    def self.type_keys
      container.keys
    end

    private

    # @api private
    def self.const_missing(const)
      underscored = Inflecto.underscore(const)

      if type_keys.any? { |key| key.split('.')[0] == underscored }
        raise NameError,
              'dry-types does not define constants for default types. '\
              'You can access the predefined types with [], e.g. Dry::Types["strict.int"] '\
              'or generate a module with types using Dry::Types.module'
      else
        super
      end
    end
  end
end

require 'dry/types/core' # load built-in types
require 'dry/types/extensions'
