require 'bigdecimal'
require 'date'

require 'dry-container'

require 'dry/data/container'
require 'dry/data/hash'
require 'dry/data/error'
require 'dry/data/struct'
require 'dry/data/type'
require 'dry/data/version'

module Dry
  module Data
    @container = Container.new

    class << self
      extend Forwardable
      def_delegators :@container, :register, :[]
    end

    register(:string, Kernel.method(:String))
    register(:int, Kernel.method(:Integer), coerces_from: String)
    register(:float, Kernel.method(:Float))
    register(:decimal, Kernel.method(:BigDecimal))
    register(:array, Kernel.method(:Array))
    register(:hash, Kernel.method(:Hash))
  end
end
