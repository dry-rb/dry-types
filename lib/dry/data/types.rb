module Dry
  module Data
    def self.strict_constructor(primitive, input)
      if input.instance_of?(primitive)
        input
      else
        raise TypeError, "#{input.inspect} has invalid type"
      end
    end

    def self.passthrough_constructor(input)
      input
    end

    COERCIBLE = {
      string: String,
      int: Integer,
      float: Float,
      decimal: BigDecimal,
      array: Array,
      hash: Hash
    }.freeze

    NON_COERCIBLE = {
      nil: NilClass,
      true: TrueClass,
      false: FalseClass,
      date: Date,
      date_time: DateTime,
      time: Time
    }.freeze

    ALL_PRIMITIVES = COERCIBLE.merge(NON_COERCIBLE).freeze

    # Register built-in primitive types with kernel coercion methods
    COERCIBLE.each do |name, primitive|
      register("coercible.#{name}", Type.new(Kernel.method(primitive.name), primitive))
    end

    # Register built-in types that are non-coercible through kernel methods
    ALL_PRIMITIVES.each do |name, primitive|
      register("strict.#{name}", Type.new(method(:strict_constructor).to_proc.curry.(primitive), primitive))
    end

    # Register built-in types that are non-coercible through kernel methods
    ALL_PRIMITIVES.each do |name, primitive|
      register(name.to_s, Type.new(method(:passthrough_constructor), primitive))
    end

    # Register non-coercible maybe types
    ALL_PRIMITIVES.each do |name, primitive|
      next if name == :nil
      register("maybe.strict.#{name}", self["strict.nil"] | self["strict.#{name}"])
    end

    # Register coercible maybe types
    COERCIBLE.each do |name, primitive|
      register("maybe.coercible.#{name}", self["strict.nil"] | self["coercible.#{name}"])
    end

    # Register :bool since it's common and not a built-in Ruby type :(
    register("strict.bool", self["strict.true"] | self["strict.false"])
  end
end
