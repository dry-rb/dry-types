# frozen_string_literal: true

require 'dry/types/primitive_inferrer'

RSpec.describe Dry::Types::PrimitiveInferrer, '#[]' do
  subject(:inferrer) do
    Dry::Types::PrimitiveInferrer.new
  end

  before { stub_const('Types', Dry.Types()) }

  def type(*args)
    args.map { |name| Dry::Types[name.to_s] }.reduce(:|)
  end

  it 'caches results' do
    expect(inferrer[type(:string)]).to be(inferrer[type(:string)])
  end

  it 'returns String for a string type' do
    expect(inferrer[type(:string)]).to eql([String])
  end

  it 'returns Integer for a integer type' do
    expect(inferrer[type(:integer)]).to eql([Integer])
  end

  it 'returns Array for a string type' do
    expect(inferrer[type(:array)]).to eql([Array])
  end

  it 'returns Array for a primitive array' do
    expect(inferrer[Types.Constructor(Array)]).to eql([Array])
  end

  it 'returns Hash for a string type' do
    expect(inferrer[type(:hash)]).to eql([Hash])
  end

  it 'returns DateTime for a datetime type' do
    expect(inferrer[type(:date_time)]).to eql([DateTime])
  end

  it 'returns NilClass for a nil type' do
    expect(inferrer[type(:nil)]).to eql([NilClass])
  end

  it 'returns FalseClass for a false type' do
    expect(inferrer[type(:false)]).to eql([FalseClass])
  end

  it 'returns TrueClass for a true type' do
    expect(inferrer[type(:true)]).to eql([TrueClass])
  end

  it 'returns FalseClass for a false type' do
    expect(inferrer[type(:false)]).to eql([FalseClass])
  end

  it 'returns [TrueClass, FalseClass] for bool type' do
    expect(inferrer[type(:bool)]).to eql([TrueClass, FalseClass])
  end

  it 'returns Integer for a lax constructor integer type' do
    expect(inferrer[type('params.integer').lax]).to eql([Integer])
  end

  it 'returns [NilClass, Integer] from an optional integer with constructor' do
    expect(inferrer[type(:integer).optional.constructor(&:to_i)]).to eql([NilClass, Integer])
  end

  it 'returns Integer for integer enum type' do
    expect(inferrer[type(:integer).enum(1, 2)]).to eql([Integer])
  end

  it 'returns custom type for arbitrary types' do
    custom_type = Dry::Types::Nominal.new(double(:some_type, name: 'ObjectID'))

    expect(inferrer[custom_type]).to eql([custom_type.primitive])
  end

  it 'returns Object for any' do
    expect(inferrer[type(:any)]).to eql([Object])
  end

  it 'returns Hash for a schema' do
    expect(inferrer[type(:hash).schema(foo: type(:integer))]).to eql([Hash])
  end
end
