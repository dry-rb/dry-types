module Dry
  module Types
    module Coercions
      include Dry::Core::Constants

      # @param [String, Object] input
      # @return [nil] if the input is an empty string
      # @return [Object] otherwise the input object is returned
      def to_nil(input, &block)
        if input.nil? || empty_str?(input)
          nil
        elsif block_given?
          yield
        else
          raise CoercionError.new("#{ input.inspect } is not nil")
        end
      end

      # @param [#to_str, Object] input
      # @return [Date, Object]
      # @see Date.parse
      def to_date(input, &block)
        if input.respond_to?(:to_str)
          ::Date.parse(input)
        else
          CoercionError.handle("#{ input.inspect } is not a string", &block)
        end
      rescue ArgumentError, RangeError => error
        CoercionError.handle(error, &block)
      end

      # @param [#to_str, Object] input
      # @return [DateTime, Object]
      # @see DateTime.parse
      def to_date_time(input, &block)
        if input.respond_to?(:to_str)
          ::DateTime.parse(input)
        else
          CoercionError.handle("#{ input.inspect } is not a string", &block)
        end
      rescue ArgumentError => error
        CoercionError.handle(error, &block)
      end

      # @param [#to_str, Object] input
      # @return [Time, Object]
      # @see Time.parse
      def to_time(input, &block)
        if input.respond_to?(:to_str)
          ::Time.parse(input)
        else
          CoercionError.handle("#{ input.inspect } is not a string", &block)
        end
      rescue ArgumentError => error
        CoercionError.handle(error, &block)
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
