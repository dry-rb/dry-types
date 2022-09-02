# frozen_string_literal: true

module Dry
  module Types
    # Range type can be used to define a range with optional member type
    #
    # @api public
    class Range < Nominal
      # Build a range type with a member type
      #
      # @param [Type,#call] type
      #
      # @return [Range::Member]
      #
      # @api public
      def of(type)
        member =
          case type
          when String then Types[type]
          else type
          end

        Range::Member.new(primitive, **options, member: member)
      end

      # @api private
      def constructor_type
        ::Dry::Types::Range::Constructor
      end
    end
  end
end
