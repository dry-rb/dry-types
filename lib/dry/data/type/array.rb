module Dry
  module Data
    class Type
      class Array < Type
        def self.constructor(array_constructor, member_constructor, input)
          array_constructor[input].map(&member_constructor)
        end

        def member(type)
          member_constructor =
            case type
            when Type then type.constructor
            when Class then Data[type].constructor
            else
              raise ArgumentError, "+#{type}+ is an unsupported array member"
            end

          array_constructor = self.class
            .method(:constructor).to_proc.curry.(constructor, member_constructor)

          self.class.new(array_constructor, primitive)
        end
      end
    end
  end
end
