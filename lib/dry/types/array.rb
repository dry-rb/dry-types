require 'dry/types/array/member'

module Dry
  module Types
    class Array < Definition
      # @param [Type] type
      # @return [Array::Member]
      def member(type)
        member =
          case type
          when String, Class then Types[type]
          else type
          end

        Array::Member.new(primitive, options.merge(member: member))
      end
    end
  end
end
