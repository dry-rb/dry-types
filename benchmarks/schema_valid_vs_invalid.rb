# frozen_string_literal: true

require_relative "setup"

VALID_INPUT = {
  name: "John",
  age: 20,
  email: "john@doe.com"
}.freeze

INVALID_INPUT = {
  name: :John,
  age: "20",
  email: nil
}.freeze

Benchmark.ips do |x|
  x.report("valid input") { PersonSchema.(VALID_INPUT) }
  x.report("invalid input") { PersonSchema.(INVALID_INPUT) }
  x.compare!
end
