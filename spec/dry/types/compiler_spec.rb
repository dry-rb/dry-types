require 'dry/types/compiler'

RSpec.describe Dry::Types::Compiler, '#call' do
  subject(:compiler) { Dry::Types::Compiler.new(Dry::Types) }

  it 'builds a safe coercible hash' do
    ast = [
      :type, [
        'hash', [
          :permissive, [
            [:key, [:email, [:type, 'string']]],
            [:key, [:age, [:type, 'form.int']]],
            [:key, [:admin, [:type, 'form.bool']]],
            [:key, [:address, [
              :type, [
                'hash', [
                  :permissive, [
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

    expect(hash).to be_instance_of(Dry::Types::Hash::Permissive)

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
      Dry::Types::MissingKeyError, /email/
    )
  end

  it 'builds a strict hash' do
    ast = [
      :type, [
        'hash', [
          :strict, [
            [:key, [:email, [:type, 'string']]],
          ]
        ]
      ]
    ]

    hash = compiler.(ast)

    expect(hash).to be_instance_of(Dry::Types::Hash::Strict)

    params = { email: 'jane@doe.org', unexpected1: 'wow', unexpected2: 'wow' }
    expect { hash[params] }
      .to raise_error(Dry::Types::UnknownKeysError, /unexpected1, :unexpected2/)

    expect(hash[email: 'jane@doe.org']).to eql(email: 'jane@doe.org')
  end

  it 'builds a coercible hash' do
    ast = [
      :type, [
        'hash', [
          :weak, [
            [:key, [:email, [:type, 'string']]],
            [:key, [:age, [:sum, [[:type, 'form.nil'], [:type, 'form.int']]]]],
            [:key, [:admin, [:type, 'form.bool']]]
          ]
        ]
      ]
    ]

    hash = compiler.(ast)

    expect(hash).to be_instance_of(Dry::Types::Hash::Weak)

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

    expect(hash).to be_instance_of(Dry::Types::Hash::Symbolized)

    expect(hash['foo' => 'bar', 'email' => 'jane@doe.org', 'age' => '20', 'admin' => '1']).to eql(
      email: 'jane@doe.org', age: 20, admin: true
    )

    expect(hash['foo' => 'bar', 'age' => '20', 'admin' => '1']).to eql(
      age: 20, admin: true
    )
  end

  it 'builds a hash with empty schema' do
    ast = [
      :type, [
        'hash', [:schema, []]
      ]
    ]

    hash = compiler.(ast)

    expect(hash['foo' => 'bar']).to eql({})
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

    expect(arr).to be_instance_of(Dry::Types::Array::Member)

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

  it 'builds a safe form array' do
    ast = [:type, ['form.array']]

    arr = compiler.(ast)

    expect(arr['oops']).to eql('oops')
    expect(arr['']).to eql([])
    expect(arr[%w(a b c)]).to eql(%w(a b c))
  end

  it 'builds a safe form array with member' do
    ast = [:type, ['form.array', [:type, ['coercible.int']]]]

    arr = compiler.(ast)

    expect(arr['oops']).to eql('oops')
    expect(arr[%w(1 2 3)]).to eql([1, 2, 3])
  end

  it 'builds a safe form hash' do
    ast = [
      :type, [
        'form.hash', [
          :symbolized, [
            [:key, [:email, [:type, 'string']]],
            [:key, [:age, [:type, 'form.int']]],
            [:key, [:admin, [:type, 'form.bool']]]
          ]
        ]
      ]
    ]

    hash = compiler.(ast)

    expect(hash['oops']).to eql('oops')

    expect(hash['foo' => 'bar', 'email' => 'jane@doe.org', 'age' => '20', 'admin' => '1']).to eql(
      email: 'jane@doe.org', age: 20, admin: true
    )

    expect(hash['foo' => 'bar', 'age' => '20', 'admin' => '1']).to eql(
      age: 20, admin: true
    )
  end

  it 'builds an schema-less form.hash' do
    ast = [:type, ['form.hash']]

    type = compiler.(ast)

    expect(type[nil]).to be(nil)
    expect(type[{}]).to eql({})
  end

  it 'builds a constructor' do
    fn = -> v { v.to_s }

    ast = [:constructor, [String, fn]]

    type = compiler.(ast)

    expect(type[:foo]).to eql('foo')

    expect(type.fn).to be(fn)
    expect(type.primitive).to be(String)
  end
end
