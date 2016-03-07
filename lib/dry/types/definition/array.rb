module Dry
  module Types
    class Definition
      class Array < Definition
        def self.constructor(member_constructor, array)
          array.map { |value| member_constructor[value] }
        end

        def member(type)
          member_constructor =
            case type
            when String, Class then Types[type]
            else type
            end

          array_constructor = self.class
            .method(:constructor).to_proc.curry.(member_constructor)

          constructor(array_constructor, member: member_constructor)
        end
      end
    end
  end
end
