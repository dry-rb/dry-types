require 'dry/types/array/member'

module Dry
  module Types
    class Array < Nominal
      # @param [Type] type
      # @return [Array::Member]
      def of(type)
        member =
          case type
          when String then Types[type]
          else type
          end

        Array::Member.new(primitive, **options, member: member)
      end
    end
  end
end
