# frozen_string_literal: true

require 'dry/core/deprecations'

module Dry
  module Types
    module Type
      extend ::Dry::Core::Deprecations[:'dry-types']

      deprecate(:safe, :lax)

      def valid?(input = Undefined)
        self.(input) { return false }
        true
      end
      alias_method :===, :valid?
    end
  end
end
