module Dry
  module Data
    class Type
      class Hash < Type
        def self.constructor(hash_constructor, value_constructors, input)
          attributes = hash_constructor[input]

          value_constructors.each_with_object({}) { |(key, value_constructor), result|
            result[key] = value_constructor[attributes.fetch(key)]
          }
        end

        def schema(type_map)
          value_constructors = type_map.each_with_object({}) { |(name, type_id), result|
            result[name] = Data[type_id]
          }

          self.class.new(
            self.class.method(:constructor).to_proc.curry.(constructor, value_constructors),
            primitive
          )
        end
      end
    end
  end
end
