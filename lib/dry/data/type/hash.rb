module Dry
  module Data
    class Type
      class Hash < Type
        def self.safe_constructor(hash_constructor, value_constructors, input)
          attributes = hash_constructor[input]

          value_constructors.each_with_object({}) do |(key, value_constructor), result|
            if attributes.key?(key)
              result[key] = value_constructor[attributes[key]]
            end
          end
        end

        def self.symbolized_constructor(hash_constructor, value_constructors, input)
          attributes = hash_constructor[input]

          value_constructors.each_with_object({}) do |(key, value_constructor), result|
            key_name = key.to_s

            if attributes.key?(key_name)
              result[key.to_sym] = value_constructor[attributes[key_name]]
            end
          end
        end

        def self.strict_constructor(hash_constructor, value_constructors, input)
          attributes = hash_constructor[input]

          value_constructors.each_with_object({}) do |(key, value_constructor), result|
            begin
              value = attributes.fetch(key)
              result[key] = value_constructor[value]
            rescue TypeError
              raise SchemaError.new(key, value)
            rescue KeyError
              raise SchemaKeyError.new(key)
            end
          end
        end

        def strict(type_map)
          schema(type_map, :strict_constructor)
        end

        def symbolized(type_map)
          schema(type_map, :symbolized_constructor)
        end

        def schema(type_map, meth = :safe_constructor)
          value_constructors = type_map.each_with_object({}) { |(name, type), result|
            result[name] =
              case type
              when String, Class then Data[type]
              else type
              end
          }

          self.class.new(
            self.class.method(meth).to_proc.curry.(constructor, value_constructors),
            primitive
          )
        end
      end
    end
  end
end
