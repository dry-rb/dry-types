# frozen_string_literal: true

require 'dry/core/deprecations'

module Dry
  module Types
    module Type
      extend ::Dry::Core::Deprecations[:'dry-types']

      deprecate(:safe, :lax)

      def valid?(input = Undefined)
        call_safe(input) { return false }
        true
      end
      alias_method :===, :valid?

      def call(input = Undefined, &block)
        if block_given?
          call_safe(input, &block)
        else
          call_unsafe(input)
        end
      end
      alias_method :[], :call
    end
  end
end
