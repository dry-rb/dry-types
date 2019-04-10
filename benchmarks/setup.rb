# frozen_string_literal: true

require 'benchmark/ips'
require 'hotch'
ENV['HOTCH_VIEWER'] ||= 'open'

require 'dry/types'

PersonSchema = Dry::Types['hash'].schema(
  name: 'string',
  age: 'integer',
  email: 'string'
).lax

def profile(&block)
  Hotch(filter: 'Dry', &block)
end
