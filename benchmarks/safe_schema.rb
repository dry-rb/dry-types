require_relative 'setup'

schema = Dry::Types['params.hash'].schema(
  email?: 'string',
  age?: 'params.integer'
).safe

params = { email: 'jane@doe.org', age: '19' }

Benchmark.ips do |x|
  x.report("valid input") { schema.(params) }
  x.compare!
end

