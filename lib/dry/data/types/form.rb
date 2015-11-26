require 'dry/data/coercions/form'

module Dry
  module Data
    register('form.date') do
      Type.new(Coercions::Form.method(:to_date), Date)
    end

    register('form.date_time') do
      Type.new(Coercions::Form.method(:to_date_time), DateTime)
    end

    register('form.time') do
      Type.new(Coercions::Form.method(:to_time), Time)
    end

    register('form.bool') do
      Type.new(Coercions::Form.method(:to_bool), TrueClass)
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
