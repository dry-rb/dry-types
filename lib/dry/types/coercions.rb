module Dry
  module Types
    module Coercions
      include Dry::Core::Constants

      # @param [String, Object] input
      # @return [nil] if the input is an empty string
      # @return [Object] otherwise the input object is returned
      def to_nil(input)
        input unless empty_str?(input)
      end

      # @param [#to_str, Object] input
      # @return [Date, Object]
      # @see Date.parse
      def to_date(input)
        return input unless input.respond_to?(:to_str)
        Date.parse(input)
      rescue ArgumentError, RangeError
        input
      end

      # @param [#to_str, Object] input
      # @return [DateTime, Object]
      # @see DateTime.parse
      def to_date_time(input)
        return input unless input.respond_to?(:to_str)
        DateTime.parse(input)
      rescue ArgumentError
        input
      end

      # @param [#to_str, Object] input
      # @return [Time, Object]
      # @see Time.parse
      def to_time(input)
        return input unless input.respond_to?(:to_str)
        Time.parse(input)
      rescue ArgumentError
        input
      end

      private

      # Checks whether String is empty
      # @param [String, Object] value
      # @return [Boolean]
      def empty_str?(value)
        EMPTY_STRING.eql?(value)
      end
    end
  end
end
