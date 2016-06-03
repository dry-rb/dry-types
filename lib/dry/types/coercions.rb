module Dry
  module Types
    module Coercions
      EMPTY_STRING = ''.freeze

      def to_nil(input)
        input unless empty_str?(input)
      end

      def to_date(input)
        Date.parse(input)
      rescue ArgumentError
        input
      end

      def to_date_time(input)
        DateTime.parse(input)
      rescue ArgumentError
        input
      end

      def to_time(input)
        Time.parse(input)
      rescue ArgumentError
        input
      end

      private

      def empty_str?(value)
        EMPTY_STRING.eql?(value)
      end

      def empty?(value)
        value.nil? || empty_str?(value)
      end
    end
  end
end
