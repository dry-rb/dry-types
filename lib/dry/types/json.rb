require 'dry/types/coercions/json'

module Dry
  module Types
    register('json.nil') do
      self['nil'].constructor(Coercions::JSON.method(:to_nil))
    end

    register('json.date') do
      self['date'].constructor(Coercions::JSON.method(:to_date))
    end

    register('json.date_time') do
      self['date_time'].constructor(Coercions::JSON.method(:to_date_time))
    end

    register('json.time') do
      self['time'].constructor(Coercions::JSON.method(:to_time))
    end

    register('json.decimal') do
      self['decimal'].constructor(Coercions::JSON.method(:to_decimal))
    end

    register('json.array') do
      self['array'].safe
    end

    register('json.hash') do
      self['hash'].safe
    end
  end
end
