require 'dry/data/typed_hash'

module Dry
  module Data
    module Struct
      def self.included(klass)
        super
        klass.extend(Mixin)
        Dry::Data.register(klass, klass.method(:new))
      end

      module Mixin
        def attributes(type_def)
          schema = type_def.each_with_object({}) do |(name, const), result|
            result[name] = const.is_a?(Class) ? const.name : const
          end

          @constructor = TypedHash.new(schema)
          attr_reader(*schema.keys)
          self
        end

        def constructor
          @constructor
        end

        # OH DEAR LORD NOT AGAIN :(
        def const_missing(name)
          Data.types[name.to_s] || super
        end
      end

      def initialize(attributes)
        self.class.constructor[attributes].each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
