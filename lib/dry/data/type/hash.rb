module Dry
  module Data
    class Type
      class Hash < Type
        def schema(type_map)
          constructors = type_map.each_with_object({}) { |(name, type_id), result|
            result[name] = Data[type_id]
          }

          hash_constructor = -> input {
            attributes = constructor[input]

            constructors.each_with_object({}) { |(key, val_constructor), result|
              result[key] = val_constructor[attributes.fetch(key)]
            }
          }

          self.class.new(hash_constructor, primitive)
        end
      end
    end
  end
end
