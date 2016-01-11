require 'dry/data/coercions/form'

module Dry
  module Data
    register('form.nil') do
      Type.new(Coercions::Form.method(:to_nil), primitive: NilClass)
    end

    register('form.date') do
      Type.new(Coercions::Form.method(:to_date), primitive: Date)
    end

    register('form.date_time') do
      Type.new(Coercions::Form.method(:to_date_time), primitive: DateTime)
    end

    register('form.time') do
      Type.new(Coercions::Form.method(:to_time), primitive: Time)
    end

    register('form.true') do
      Type.new(Coercions::Form.method(:to_true), primitive: TrueClass)
    end

    register('form.false') do
      Type.new(Coercions::Form.method(:to_false), primitive: FalseClass)
    end

    register('form.bool') do
      self['form.true'] | self['form.false']
    end

    register('form.int') do
      Type.new(Coercions::Form.method(:to_int), primitive: Fixnum)
    end

    register('form.float') do
      Type.new(Coercions::Form.method(:to_float), primitive: Float)
    end

    register('form.decimal') do
      Type.new(Coercions::Form.method(:to_decimal), primitive: BigDecimal)
    end
  end
end
