require_relative 'setup'

Schema = Dry::Types['params.hash'].schema(
  email?: 'string',
  age?: 'coercible.integer'
).safe

ValidInput = { email: 'jane@doe.org', age: '19' }

profile do
  10_000.times do
    Schema.(ValidInput)
  end
end
