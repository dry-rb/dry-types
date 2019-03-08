module Dry
  module Types
    module Printable
      # @return [String]
      # @api public
      def to_s
        PRINTER.(self) { super }
      end
      alias_method :inspect, :to_s
    end
  end
end
