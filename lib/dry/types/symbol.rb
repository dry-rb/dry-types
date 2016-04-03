require 'dry/types/coercions/symbol'

module Dry
  module Types
    register('coercible.symbol') do
      self['symbol'].constructor(Coercions::Symbol.method(:to_symbol))
    end
  end
end
