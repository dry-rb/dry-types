require 'dry-container'

require 'bigdecimal'
require 'date'
require 'set'

require 'dry/data/version'
require 'dry/data/container'
require 'dry/data/type'
require 'dry/data/struct'
require 'dry/data/dsl'

module Dry
  module Data
    def self.container
      @container ||= Container.new
    end

    def self.register(name, type)
      container.register(name, type)
    end

    def self.[](name)
      container[name]
    end

    def self.type(*args, &block)
      dsl = DSL.new(container)
      block ? yield(dsl) : registry[args.first]
    end
  end
end

require 'dry/data/types' # load built-in types
