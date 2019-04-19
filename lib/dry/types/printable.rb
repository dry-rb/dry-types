# frozen_string_literal: true

module Dry
  module Types
    module Printable
      # @return [String]
      def to_s
        PRINTER.(self) { super }
      end
      alias_method :inspect, :to_s
    end
  end
end
