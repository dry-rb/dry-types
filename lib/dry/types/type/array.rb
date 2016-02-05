module Dry
  module Types
    class Type
      class Array < Type
        def self.constructor(array_constructor, member_constructor, input)
          array_constructor[input].map { |value| member_constructor[value] }
        end

        def member(type)
          member_constructor =
            case type
            when String, Class then Types[type]
            else type
            end

          array_constructor = self.class
            .method(:constructor).to_proc.curry.(constructor, member_constructor)

          self.class.new(array_constructor, primitive: primitive, member: member_constructor)
        end
      end
    end
  end
end
