require 'dry/types/array/member'
require 'dry/core/deprecations'

module Dry
  module Types
    class Array < Definition
      extend Dry::Core::Deprecations[:'dry-types']

      # @param [Type] type
      # @return [Array::Member]
      def of(type)
        member =
          case type
          when String, Class then Types[type]
          else type
          end

        Array::Member.new(primitive, **options, member: member)
      end

      deprecate :member, :of
    end
  end
end
