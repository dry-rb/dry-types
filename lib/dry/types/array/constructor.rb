# frozen_string_literal: true

require 'dry/types/constructor'

module Dry
  module Types
    # @api public
    class Array < Nominal
      # @api private
      class Constructor < ::Dry::Types::Constructor
        # @api private
        def constructor_type
          ::Dry::Types::Array::Constructor
        end

        # @return [Lax]
        #
        # @api public
        def lax
          type.lax.constructor(fn, meta: meta)
        end

        private

        # @api private
        def composable?(value)
          super && value.is_a?(Constructor)
        end
      end
    end
  end
end
