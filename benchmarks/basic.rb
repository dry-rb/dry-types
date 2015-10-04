require 'dry/data'
require 'virtus'
require 'fast_attributes'
require 'attrio'
require 'ostruct'

require 'benchmark/ips'

class VirtusUser
  include Virtus.model

  attribute :name, String
  attribute :age, Integer
end

class FastUser
  extend FastAttributes

  define_attributes initialize: true, attributes: true do
    attribute :name, String
    attribute :age,  Integer
  end
end

class AttrioUser
  include Attrio

  define_attributes do
    attr :name, String
    attr :age, Integer
  end

  def initialize(attributes = {})
    self.attributes = attributes
  end

  def attributes=(attributes = {})
    attributes.each do |attr,value|
      self.send("#{attr}=", value) if self.respond_to?("#{attr}=")
    end
  end
end

class DryDataUser < Dry::Data::Struct
  attributes(name: 'coercible.string', age: 'coercible.int')
end

puts DryDataUser.new(name: 'Jane', age: '21').inspect

Benchmark.ips do |x|
  x.report('virtus') { VirtusUser.new(name: 'Jane', age: '21') }
  x.report('fast_attributes') { FastUser.new(name: 'Jane', age: '21') }
  x.report('attrio') { AttrioUser.new(name: 'Jane', age: '21') }
  x.report('dry-data') { DryDataUser.new(name: 'Jane', age: '21') }

  x.compare!
end
