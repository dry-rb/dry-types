module Dry
  module Types
    class Definition
      class Hash < Definition
        def self.safe_constructor(value_constructors, hash)
          value_constructors.each_with_object({}) do |(key, value_constructor), result|
            if hash.key?(key)
              result[key] = value_constructor[hash[key]]
            end
          end
        end

        def self.symbolized_constructor(value_constructors, hash)
          value_constructors.each_with_object({}) do |(key, value_constructor), result|
            key_name = key.to_s

            if hash.key?(key_name)
              result[key.to_sym] = value_constructor[hash[key_name]]
            end
          end
        end

        def self.strict_constructor(value_constructors, hash)
          value_constructors.each_with_object({}) do |(key, value_constructor), result|
            begin
              value = hash.fetch(key)
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
              when String, Class then Types[type]
              else type
              end
          }

          constructor(
            self.class.method(meth).to_proc.curry.(value_constructors),
            schema: value_constructors
          )
        end
      end
    end
  end
end
