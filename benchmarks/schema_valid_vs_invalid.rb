# frozen_string_literal: true

require_relative 'setup'

VALID_INPUT = {
  name: 'John',
  age: 20,
  email: 'john@doe.com'
}

INVALID_INPUT = {
  name: :John,
  age: '20',
  email: nil
}

Benchmark.ips do |x|
  x.report("valid input") { PersonSchema.(VALID_INPUT) }
  x.report("invalid input") { PersonSchema.(INVALID_INPUT) }
  x.compare!
end
