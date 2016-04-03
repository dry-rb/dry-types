require 'date'
require 'bigdecimal'
require 'bigdecimal/util'
require 'time'

module Dry
  module Types
    module Coercions
      module JSON
        def self.to_nil(input)
          input unless input.is_a?(String) && input == ''
        end

        def self.to_date(input)
          Date.parse(input)
        rescue ArgumentError
          input
        end

        def self.to_date_time(input)
          DateTime.parse(input)
        rescue ArgumentError
          input
        end

        def self.to_time(input)
          Time.parse(input)
        rescue ArgumentError
          input
        end

        def self.to_decimal(input)
          if input.is_a?(String) && input == ''
            nil
          else
            input.to_d
          end
        end
      end
    end
  end
end
