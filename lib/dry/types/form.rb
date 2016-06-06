require 'dry/types/coercions/form'

module Dry
  module Types
    register('form.nil') do
      self['nil'].constructor(Coercions::Form.method(:to_nil))
    end

    register('form.date') do
      self['date'].constructor(Coercions::Form.method(:to_date))
    end

    register('form.date_time') do
      self['date_time'].constructor(Coercions::Form.method(:to_date_time))
    end

    register('form.time') do
      self['time'].constructor(Coercions::Form.method(:to_time))
    end

    register('form.true') do
      self['true'].constructor(Coercions::Form.method(:to_true))
    end

    register('form.false') do
      self['false'].constructor(Coercions::Form.method(:to_false))
    end

    register('form.bool') do
      (self['form.true'] | self['form.false']).safe
    end

    register('form.int') do
      self['int'].constructor(Coercions::Form.method(:to_int))
    end

    register('form.float') do
      self['float'].constructor(Coercions::Form.method(:to_float))
    end

    register('form.decimal') do
      self['decimal'].constructor(Coercions::Form.method(:to_decimal))
    end

    register('form.array') do
      self['array'].constructor(Coercions::Form.method(:to_ary)).safe
    end

    register('form.hash') do
      self['hash'].constructor(Coercions::Form.method(:to_hash)).safe
    end
  end
end
