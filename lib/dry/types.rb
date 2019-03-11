require 'bigdecimal'
require 'date'
require 'set'

require 'concurrent'

require 'dry-container'
require 'dry-equalizer'
require 'dry/core/extensions'
require 'dry/core/constants'
require 'dry/core/class_attributes'

require 'dry/types/version'
require 'dry/types/container'
require 'dry/types/inflector'
require 'dry/types/type'
require 'dry/types/printable'
require 'dry/types/definition'
require 'dry/types/constructor'
require 'dry/types/module'

require 'dry/types/errors'

module Dry
  module Types
    extend Dry::Core::Extensions
    extend Dry::Core::ClassAttributes
    include Dry::Core::Constants

    TYPE_SPEC_REGEX = %r[(.+)<(.+)>].freeze

    # @return [Module]
    def self.module(*args)
      Module.new(container, *args)
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
    # @api private
    def self.register(name, type = nil, &block)
      container.register(name, type || block.call)
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

    # @param [#to_s] klass
    # @return [String]
    def self.identifier(klass)
      Inflector.underscore(klass).tr('/', '.')
    end

    # @return [Concurrent::Map]
    def self.type_map
      @type_map ||= Concurrent::Map.new
    end

    private

    # @api private
    def self.const_missing(const)
      underscored = Inflector.underscore(const)

      if container.keys.any? { |key| key.split('.')[0] == underscored }
        raise NameError,
              'dry-types does not define constants for default types. '\
              'You can access the predefined types with [], e.g. Dry::Types["strict.integer"] '\
              'or generate a module with types using Dry::Types.module'
      else
        super
      end
    end
  end
end

require 'dry/types/core' # load built-in types
require 'dry/types/extensions'
require 'dry/types/printer'
