# frozen_string_literal: true

$LOAD_PATH.unshift('lib')

require 'bundler/setup'
require 'dry-types'

module SchemaBench
  def self.hash_schema(type)
    Dry::Types['nominal.hash'].public_send(
      type,
      email: Dry::Types['nominal.string'],
      age: Dry::Types['params.integer'],
      admin: Dry::Types['params.bool'],
      address: Dry::Types['nominal.hash'].public_send(
        type,
        city: Dry::Types['nominal.string'],
        street: Dry::Types['nominal.string']
      )
    )
  end

  private_class_method(:hash_schema)

  SCHEMAS =
    Dry::Types::Hash
      .public_instance_methods(false)
      .map { |schema_type| [schema_type, hash_schema(schema_type)] }
      .to_h

  INPUT = {
    email: 'jane@doe.org',
    age: '20',
    admin: '1',
    address: { city: 'NYC', street: 'Street 1/2' }
  }.freeze
end

require 'benchmark/ips'

Benchmark.ips do |x|
  SchemaBench::SCHEMAS.each do |schema_type, schema|
    x.report("#{schema_type}#call") do
      schema.call(SchemaBench::INPUT)
    end
  end

  SchemaBench::SCHEMAS.each do |schema_type, schema|
    x.report("#{schema_type}#try") do
      schema.try(SchemaBench::INPUT)
    end
  end

  x.compare!
end
