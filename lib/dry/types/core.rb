require 'dry/types/any'

module Dry
  module Types
    COERCIBLE = {
      string: String,
      int: Integer,
      float: Float,
      decimal: BigDecimal,
      array: ::Array,
      hash: ::Hash
    }.freeze

    NON_COERCIBLE = {
      nil: NilClass,
      symbol: Symbol,
      class: Class,
      true: TrueClass,
      false: FalseClass,
      date: Date,
      date_time: DateTime,
      time: Time
    }.freeze

    ALL_PRIMITIVES = COERCIBLE.merge(NON_COERCIBLE).freeze

    NON_NIL = ALL_PRIMITIVES.reject { |name, _| name == :nil }.freeze

    # Register built-in types that are non-coercible through kernel methods
    ALL_PRIMITIVES.each do |name, primitive|
      register(name.to_s, Definition[primitive].new(primitive))
    end

    # Register strict built-in types that are non-coercible through kernel methods
    ALL_PRIMITIVES.each do |name, primitive|
      register("strict.#{name}", self[name.to_s].constrained(type: primitive))
    end

    # Register built-in primitive types with kernel coercion methods
    COERCIBLE.each do |name, primitive|
      register("coercible.#{name}", self[name.to_s].constructor(Kernel.method(primitive.name)))
    end

    # Register non-coercible optional types
    NON_NIL.each_key do |name|
      register("optional.strict.#{name}", self["strict.#{name}"].optional)
    end

    # Register coercible optional types
    COERCIBLE.each_key do |name|
      register("optional.coercible.#{name}", self["coercible.#{name}"].optional)
    end

    # Register :bool since it's common and not a built-in Ruby type :(
    register("bool", self["true"] | self["false"])
    register("strict.bool", self["strict.true"] | self["strict.false"])

    register("any", Any)
    register("object", self['any'])
  end
end

require 'dry/types/coercions'
require 'dry/types/form'
require 'dry/types/json'
