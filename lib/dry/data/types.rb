module Dry
  module Data
    def self.constructor(primitive, input)
      if input.instance_of?(primitive)
        input
      else
        raise TypeError, "#{input.inspect} has invalid type"
      end
    end

    COERCIBLE = {
      string: String, int: Integer, float: Float, decimal: BigDecimal,
      array: Array, hash: Hash
    }.freeze

    NON_COERCIBLE = {
      true: TrueClass, false: FalseClass, date: Date,
      date_time: DateTime, time: Time
    }.freeze

    # Register built-in primitive types with kernel coercion methods
    COERCIBLE.each do |name, primitive|
      register(name, Type.new(Kernel.method(primitive.name), primitive))
    end

    # Register built-in types that are non-coercible through kernel methods
    NON_COERCIBLE.each do |name, primitive|
      register(name, Type.new(method(:constructor).curry.(primitive), primitive))
    end

    # Register :bool since it's common and not a built-in Ruby type :(
    register(:bool, self[:true] | self[:false])
  end
end
