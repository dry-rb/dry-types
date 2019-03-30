module Dry
  module Types
    module Coercions
      include Dry::Core::Constants

      # @param [String, Object] input
      # @return [nil] if the input is an empty string
      # @return [Object] otherwise the input object is returned
      def to_nil(input)
        if input.nil? || empty_str?(input)
          nil
        else
          raise CoercionError.new("#{ input.inspect } is not nil")
        end
      end

      # @param [#to_str, Object] input
      # @return [Date, Object]
      # @see Date.parse
      def to_date(input)
        unless input.respond_to?(:to_str)
          raise CoercionError("#{ input.inspect } is not a string")
        end
        Date.parse(input)
      rescue ArgumentError, RangeError => error
        raise CoercionError.new(error.message, error.backtrace)
      end

      # @param [#to_str, Object] input
      # @return [DateTime, Object]
      # @see DateTime.parse
      def to_date_time(input)
        unless input.respond_to?(:to_str)
          raise CoercionError("#{ input.inspect } is not a string")
        end
        DateTime.parse(input)
      rescue ArgumentError => error
        raise CoercionError.new(error.message, error.backtrace)
      end

      # @param [#to_str, Object] input
      # @return [Time, Object]
      # @see Time.parse
      def to_time(input)
        unless input.respond_to?(:to_str)
          raise CoercionError("#{ input.inspect } is not a string")
        end
        Time.parse(input)
      rescue ArgumentError => error
        raise CoercionError.new(error.message, error.backtrace)
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
