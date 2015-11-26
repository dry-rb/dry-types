require 'dry/data/coercions/form'

module Dry
  module Data
    register('form.date', Type.new(Date.method(:parse), Date))
    register('form.date_time', Type.new(DateTime.method(:parse), DateTime))
    register('form.time', Type.new(Time.method(:parse), Time))
    register('form.bool', Type.new(Coercions::Form.method(:to_bool), TrueClass))
    register('form.int', Type.new(Coercions::Form.method(:to_int), Fixnum))
    register('form.float', Type.new(Coercions::Form.method(:to_float), Float))
    register('form.decimal', Type.new(Coercions::Form.method(:to_decimal), BigDecimal))
  end
end
