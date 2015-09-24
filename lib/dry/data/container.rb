require 'dry/data/container/registry'
require 'dry/data/container/resolver'

module Dry
  module Data
    class Container
      include Dry::Container::Mixin

      configure do |config|
        config.registry = Registry.new
        config.resolver = Resolver.new
      end
    end
  end
end
