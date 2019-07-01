# frozen_string_literal: true

require_relative 'setup'

Schema = Dry::Types['params.hash'].schema(
  email?: 'string',
  age?: 'coercible.integer'
).lax

ValidInput = { email: 'jane@doe.org', age: '19' }.freeze

profile do
  10_000.times do
    Schema.(ValidInput)
  end
end
