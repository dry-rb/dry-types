# frozen_string_literal: true

module Dry
  module Types
    module Builder
      # Build a type that returns `nil` on invalid input
      #
      # @return [Constructor]
      #
      # @api public
      def or_nil
        optional.fallback(nil)
      end
    end
  end
end
