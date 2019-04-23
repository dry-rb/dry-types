# frozen_string_literal: true

require 'dry/types/constructor'

module Dry
  module Types
    # Hash type exposes additional APIs for working with schema hashes
    #
    # @api public
    class Hash < Nominal
      class Constructor < ::Dry::Types::Constructor
        # @api private
        def constructor_type
          ::Dry::Types::Hash::Constructor
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
          super && !value.is_a?(Schema::Key)
        end
      end
    end
  end
end
