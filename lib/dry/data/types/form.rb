require 'dry/data/coercions/form'

module Dry
  module Data
    register('form.nil') do
      Type.new(Coercions::Form.method(:to_nil), NilClass)
    end

    register('form.date') do
      Type.new(Coercions::Form.method(:to_date), Date)
    end

    register('form.date_time') do
      Type.new(Coercions::Form.method(:to_date_time), DateTime)
    end

    register('form.time') do
      Type.new(Coercions::Form.method(:to_time), Time)
    end

    register('form.true') do
      Type.new(Coercions::Form.method(:to_true), TrueClass)
    end

    register('form.false') do
      Type.new(Coercions::Form.method(:to_true), FalseClass)
    end

    register('form.bool') do
      self['form.true'] | self['form.false']
    end

    register('form.int') do
      Type.new(Coercions::Form.method(:to_int), Fixnum)
    end

    register('form.float') do
      Type.new(Coercions::Form.method(:to_float), Float)
    end

    register('form.decimal') do
      Type.new(Coercions::Form.method(:to_decimal), BigDecimal)
    end
  end
end
