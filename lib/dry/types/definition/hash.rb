module Dry
  module Types
    class Definition
      class Hash < Definition
        def self.safe_constructor(types, hash)
          types.each_with_object({}) do |(key, type), result|
            if hash.key?(key)
              result[key] = type[hash[key]]
            elsif type.is_a?(Default)
              result[key] = type.value
            end
          end
        end

        def self.symbolized_constructor(types, hash)
          types.each_with_object({}) do |(key, type), result|
            key_name = key.to_s

            if hash.key?(key_name)
              result[key.to_sym] = type[hash[key_name]]
            end
          end
        end

        def self.strict_constructor(types, hash)
          types.each_with_object({}) do |(key, type), result|
            begin
              value = hash.fetch(key)
              result[key] = type[value]
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
          types = type_map.each_with_object({}) { |(name, type), result|
            result[name] =
              case type
              when String, Class then Types[type]
              else type
              end
          }

          fn = self.class.method(meth).to_proc.curry.(types)

          constructor(fn, schema: types)
        end
      end
    end
  end
end
