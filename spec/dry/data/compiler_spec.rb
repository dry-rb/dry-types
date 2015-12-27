require 'dry/data/compiler'

RSpec.describe Dry::Data::Compiler, '#call' do
  subject(:compiler) { Dry::Data::Compiler.new(Dry::Data) }

  it 'builds a safe coercible hash' do
    ast = [
      :type, [
        'hash', [
          :strict, [
            [:key, [:email, [:type, 'string']]],
            [:key, [:age, [:type, 'form.int']]],
            [:key, [:admin, [:type, 'form.bool']]],
            [:key, [:address, [
              :type, [
                'hash', [
                  :strict, [
                    [:key, [:city, [:type, 'string']]],
                    [:key, [:street, [:type, 'string']]]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]]]

    hash = compiler.(ast)

    expect(hash).to be_instance_of(Dry::Data::Type::Hash)

    result = hash[
      email: 'jane@doe.org',
      age: '20',
      admin: '1',
      address: { city: 'NYC', street: 'Street 1/2' }
    ]

    expect(result).to eql(
      email: 'jane@doe.org', age: 20, admin: true,
      address: { city: 'NYC', street: 'Street 1/2' }
    )

    expect { hash[foo: 'jane@doe.org', age: '20', admin: '1'] }.to raise_error(
      Dry::Data::SchemaKeyError, /email/
    )
  end

  it 'builds a coercible hash' do
    ast = [
      :type, [
        'hash', [
          :schema, [
            [:key, [:email, [:type, 'string']]],
            [:key, [:age, [:sum, [[:type, 'form.nil'], [:type, 'form.int']]]]],
            [:key, [:admin, [:type, 'form.bool']]]
          ]
        ]
      ]
    ]

    hash = compiler.(ast)

    expect(hash).to be_instance_of(Dry::Data::Type::Hash)

    result = hash[foo: 'bar', email: 'jane@doe.org', age: '20', admin: '1']

    expect(result).to eql(email: 'jane@doe.org', age: 20, admin: true)

    result = hash[foo: 'bar', email: 'jane@doe.org', age: '', admin: '1']

    expect(result).to eql(email: 'jane@doe.org', age: nil, admin: true)

    result = hash[foo: 'bar', email: 'jane@doe.org', admin: '1']

    expect(result).to eql(email: 'jane@doe.org', admin: true)
  end

  it 'builds a coercible hash with symbolized keys' do
    ast = [
      :type, [
        'hash', [
          :symbolized, [
            [:key, [:email, [:type, 'string']]],
            [:key, [:age, [:type, 'form.int']]],
            [:key, [:admin, [:type, 'form.bool']]]
          ]
        ]
      ]
    ]

    hash = compiler.(ast)

    expect(hash).to be_instance_of(Dry::Data::Type::Hash)

    expect(hash['foo' => 'bar', 'email' => 'jane@doe.org', 'age' => '20', 'admin' => '1']).to eql(
      email: 'jane@doe.org', age: 20, admin: true
    )

    expect(hash['foo' => 'bar', 'age' => '20', 'admin' => '1']).to eql(
      age: 20, admin: true
    )
  end

  it 'builds an array' do
    ast = [
      :type, [
        'array', [
          :type, [
            'hash', [
              :symbolized, [
                [:key, [:email, [:type, 'string']]],
                [:key, [:age, [:type, 'form.int']]],
                [:key, [:admin, [:type, 'form.bool']]]
              ]
            ]
          ]
        ]
      ]
    ]

    arr = compiler.(ast)

    expect(arr).to be_instance_of(Dry::Data::Type::Array)

    input = [
      'foo' => 'bar', 'email' => 'jane@doe.org', 'age' => '20', 'admin' => '1'
    ]

    expect(arr[input]).to eql([
      email: 'jane@doe.org', age: 20, admin: true
    ])

    expect(arr[['foo' => 'bar', 'age' => '20', 'admin' => '1']]).to eql([
      age: 20, admin: true
    ])
  end
end
