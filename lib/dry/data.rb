require 'bigdecimal'
require 'date'

require 'dry/data/version'
require 'dry/data/registry'
require 'dry/data/type'
require 'dry/data/struct'
require 'dry/data/dsl'

module Dry
  module Data
    def self.registry
      @registry ||= Registry.new
    end

    def self.register(const, constructor)
      register_constructor(const, constructor)
      register_type(Data.type(const.name))
    end

    def self.register_type(type, name = type.name)
      types[name.freeze] = type
    end

    def self.register_constructor(const, constructor)
      registry[const.name] = [constructor, const]
    end

    def self.type(*args, &block)
      dsl = DSL.new(registry)
      block ? yield(dsl) : dsl[args.first]
    end

    def self.types
      @types ||= {}
    end

    def self.[](name)
      types[name] # silly delegation for now TODO: raise nice error if type is not found
    end
  end
end

require 'dry/data/types' # load built-in types
