require 'dry/types'

require 'active_record'
require 'benchmark/ips'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |table|
    table.column :name, :string
    table.column :age, :integer
  end
end

class ARUser < ActiveRecord::Base
  self.table_name = :users
end

module Types
  include Dry::Types.module
end

class DryTypesUser < Dry::Types::Struct
  attribute :id, Types::Form::Int
  attribute :name, Types::Strict::String.constrained(size: 3..64)
  attribute :age, Types::Form::Int.constrained(gt: 18)
end

puts ARUser.new(id: 1, name: 'Jane', age: '21').inspect
puts DryTypesUser.new(id: 1, name: 'Jane', age: '21').inspect

Benchmark.ips do |x|
  x.report('active record') { ARUser.new(id: 1, name: 'Jane', age: '21') }
  x.report('dry-types') { DryTypesUser.new(id: 1, name: 'Jane', age: '21') }

  x.compare!
end
