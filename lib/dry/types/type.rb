# frozen_string_literal: true

require 'dry/core/deprecations'

module Dry
  module Types
    module Type
      extend ::Dry::Core::Deprecations[:'dry-types']

      deprecate(:safe, :lax)
    end
  end
end
