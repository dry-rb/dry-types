# frozen_string_literal: true

require_relative 'setup'

VALID_INPUT = {
  name: 'John',
  age: 20,
  email: 'john@doe.com'
}.freeze

profile do
  10_000.times do
    PersonSchema.(VALID_INPUT)
  end
end
