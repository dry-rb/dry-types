# frozen_string_literal: true

require 'dry/types/array/member'

module Dry
  module Types
    # Array type can be used to define an array with optional member type
    #
    # @api public
    class Array < Nominal
      # Build an array type with a member type
      #
      # @param [Type,#call] type
      #
      # @return [Array::Member]
      #
      # @api public
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
