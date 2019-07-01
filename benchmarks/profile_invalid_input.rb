# frozen_string_literal: true

require_relative 'setup'

INVALID_INPUT = {
  name: :John,
  age: '20',
  email: nil
}.freeze

profile do
  10_000.times do
    PersonSchema.(INVALID_INPUT)
  end
end
