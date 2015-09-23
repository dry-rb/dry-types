module Dry
  module Data
    COERCIBLE = [String, Integer, Float, BigDecimal, Array, Hash].freeze
    NON_COERCIBLE = [TrueClass, FalseClass, Date, DateTime, Time].freeze

    # Register built-in primitive types with kernel coercion methods
    COERCIBLE.each do |const|
      register(const, Kernel.method(const.name))
    end

    # Register built-in types that are non-coercible through kernel methods
    NON_COERCIBLE.each do |const|
      register(
        const,
        -> input {
          if input.instance_of?(const)
            input
          else
            raise(TypeError, "#{input.inspect} has invalid type")
          end
        }
      )
    end

    # Register Bool since it's common and not a built-in Ruby type :(
    #
    # We store it under a constant in case somebody would like to refer to it
    # explicitly
    Bool = Data.new { |t| t['TrueClass'] | t['FalseClass'] }
    register_type(Bool, 'Bool')
  end
end
