require 'benchmark/ips'
require 'hotch'
ENV['HOTCH_VIEWER'] ||= 'open'

require 'dry/types'

PersonSchema = Dry::Types['hash'].schema(
  name: 'string',
  age: 'integer',
  email: 'string'
).safe

def profile(&block)
  Hotch(filter: 'Dry', &block)
end
