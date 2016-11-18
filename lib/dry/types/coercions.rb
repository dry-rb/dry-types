module Dry
  module Types
    module Coercions
      def to_nil(input)
        input unless empty_str?(input)
      end

      def to_date(input)
        return input unless input.respond_to?(:to_str)
        Date.parse(input)
      rescue ArgumentError
        input
      end

      def to_date_time(input)
        return input unless input.respond_to?(:to_str)
        DateTime.parse(input)
      rescue ArgumentError
        input
      end

      def to_time(input)
        return input unless input.respond_to?(:to_str)
        Time.parse(input)
      rescue ArgumentError
        input
      end

      private

      def empty_str?(value)
        EMPTY_STRING.eql?(value)
      end
    end
  end
end
