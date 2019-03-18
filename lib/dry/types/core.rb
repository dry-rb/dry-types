require 'dry/types/any'

module Dry
  module Types
    # Primitives with {Kernel} coercion methods
    COERCIBLE = {
      string: String,
      integer: Integer,
      float: Float,
      decimal: BigDecimal,
      array: ::Array,
      hash: ::Hash
    }.freeze

    # Primitives that are non-coercible through {Kernel} methods
    NON_COERCIBLE = {
      nil: NilClass,
      symbol: Symbol,
      class: Class,
      true: TrueClass,
      false: FalseClass,
      date: Date,
      date_time: DateTime,
      time: Time,
      range: Range
    }.freeze

    # All built-in primitives
    ALL_PRIMITIVES = COERCIBLE.merge(NON_COERCIBLE).freeze

    # All built-in primitives except {NilClass}
    NON_NIL = ALL_PRIMITIVES.reject { |name, _| name == :nil }.freeze

    # Register generic types for {ALL_PRIMITIVES}
    ALL_PRIMITIVES.each do |name, primitive|
      type = Definition[primitive].new(primitive)
      register(name.to_s, type)
      register("nominal.#{name}", type)
    end

    # Register strict types for {ALL_PRIMITIVES}
    ALL_PRIMITIVES.each do |name, primitive|
      register("strict.#{name}", self[name.to_s].constrained(type: primitive))
    end

    # Register {COERCIBLE} types
    COERCIBLE.each do |name, primitive|
      register("coercible.#{name}", self[name.to_s].constructor(Kernel.method(primitive.name)))
    end

    # Register optional strict {NON_NIL} types
    NON_NIL.each_key do |name|
      register("optional.strict.#{name}", self["strict.#{name}"].optional)
    end

    # Register optional {COERCIBLE} types
    COERCIBLE.each_key do |name|
      register("optional.coercible.#{name}", self["coercible.#{name}"].optional)
    end

    # Register `:bool` since it's common and not a built-in Ruby type :(
    register("bool", self["true"] | self["false"])
    register("strict.bool", self["strict.true"] | self["strict.false"])

    register("any", Any)
  end
end

require 'dry/types/coercions'
require 'dry/types/params'
require 'dry/types/json'
