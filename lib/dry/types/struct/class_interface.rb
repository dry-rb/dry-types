module Dry
  module Types
    class Struct
      module ClassInterface
        include Builder

        attr_accessor :constructor

        attr_accessor :equalizer

        attr_writer :constructor_type

        protected :constructor=, :equalizer=, :constructor_type=

        def inherited(klass)
          super

          klass.equalizer = Equalizer.new(*schema.keys)
          klass.constructor_type = constructor_type
          klass.send(:include, klass.equalizer)

          unless klass == Value
            klass.constructor = Types['coercible.hash']
            Types.register(Types.identifier(klass), klass)
          end

          klass.attributes({}) unless equal?(Struct)
        end

        def attribute(name, type)
          attributes(name => type)
        end

        def attributes(new_schema)
          check_schema_duplication(new_schema)

          prev_schema = schema

          @schema = prev_schema.merge(new_schema)
          @constructor = Types['coercible.hash'].public_send(constructor_type, schema)

          attr_reader(*new_schema.keys)
          equalizer.instance_variable_get('@keys').concat(new_schema.keys)

          self
        end

        def check_schema_duplication(new_schema)
          shared_keys = new_schema.keys & schema.keys

          fail RepeatedAttributeError, shared_keys.first if shared_keys.any?
        end
        private :check_schema_duplication

        def constructor_type(type = nil)
          if type
            @constructor_type = type
          else
            @constructor_type || :strict
          end
        end

        def schema
          super_schema = superclass.respond_to?(:schema) ? superclass.schema : {}
          super_schema.merge(@schema || {})
        end

        def new(attributes = default_attributes)
          if attributes.instance_of?(self)
            attributes
          else
            super(constructor[attributes])
          end
        rescue SchemaError, SchemaKeyError => error
          raise StructError, "[#{self}.new] #{error}"
        end
        alias_method :call, :new
        alias_method :[], :new

        def default_attributes
          schema.each_with_object({}) { |(name, type), result|
            result[name] = type.default? ? type.evaluate : type[nil]
          }
        end

        def try(input)
          Result::Success.new(self[input])
        rescue StructError => e
          failure = Result::Failure.new(input, e.message)
          block_given? ? yield(failure) : failure
        end

        def maybe?
          false
        end

        def default?
          false
        end

        def valid?(value)
          self === value
        end
      end
    end
  end
end
