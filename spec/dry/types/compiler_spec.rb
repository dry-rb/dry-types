require 'dry/types/compiler'

RSpec.describe Dry::Types::Compiler, '#call' do
  subject(:compiler) { Dry::Types::Compiler.new(Dry::Types) }

  it 'returns existing definition' do
    ast = [:definition, [Hash, {}]]
    type = compiler.(ast)

    expect(type).to be(Dry::Types['hash'])
  end

  it 'builds a plain definition' do
    ast = [:definition, [Set, {}]]
    type = compiler.(ast)
    expected = Dry::Types::Definition.new(Set)

    expect(type).to eql(expected)
  end

  it 'builds a definition with meta' do
    ast = [:definition, [Set, key: :value]]
    type = compiler.(ast)
    expected = Dry::Types::Definition.new(Set, meta: { key: :value })

    expect(type).to eql(expected)
  end

  it 'builds a safe coercible hash' do
    ast = Dry::Types['hash'].permissive(
      email: Dry::Types['string'],
      age: Dry::Types['form.int'],
      admin: Dry::Types['form.bool'],
      address: Dry::Types['hash'].permissive(
        city: Dry::Types['string'],
        street: Dry::Types['string']
      )
    ).to_ast

    hash = compiler.(ast)

    expect(hash).to be_a(Dry::Types::Hash)

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
    ast = Dry::Types['hash'].strict(
      email: Dry::Types['string']
    ).to_ast

    hash = compiler.(ast)

    expect(hash).to be_a(Dry::Types::Hash)

    params = { email: 'jane@doe.org', unexpected1: 'wow', unexpected2: 'wow' }
    expect { hash[params] }
      .to raise_error(Dry::Types::UnknownKeysError, /unexpected1, :unexpected2/)

    expect(hash[email: 'jane@doe.org']).to eql(email: 'jane@doe.org')
  end

  it 'builds a coercible hash' do
    ast = Dry::Types['hash'].weak(
      email: Dry::Types['string'],
      age: Dry::Types['form.nil'] | Dry::Types['form.int'],
      admin: Dry::Types['form.bool']
    ).to_ast

    hash = compiler.(ast)

    expect(hash).to be_a(Dry::Types::Hash)

    result = hash[foo: 'bar', email: 'jane@doe.org', age: '20', admin: '1']

    expect(result).to eql(email: 'jane@doe.org', age: 20, admin: true)

    result = hash[foo: 'bar', email: 'jane@doe.org', age: '', admin: '1']

    expect(result).to eql(email: 'jane@doe.org', age: nil, admin: true)

    result = hash[foo: 'bar', email: 'jane@doe.org', admin: '1']

    expect(result).to eql(email: 'jane@doe.org', admin: true)
  end

  it 'builds a coercible hash with symbolized keys' do
    ast = Dry::Types['hash'].symbolized(
      email: Dry::Types['string'],
      age: Dry::Types['form.int'],
      admin: Dry::Types['form.bool']
    ).to_ast

    hash = compiler.(ast)

    expect(hash).to be_a(Dry::Types::Hash)

    expect(hash['foo' => 'bar', 'email' => 'jane@doe.org', 'age' => '20', 'admin' => '1']).to eql(
      email: 'jane@doe.org', age: 20, admin: true
    )

    expect(hash['foo' => 'bar', 'age' => '20', 'admin' => '1']).to eql(
      age: 20, admin: true
    )
  end

  it 'builds a hash with empty schema' do

    ast = Dry::Types['hash'].schema([]).to_ast

    hash = compiler.(ast)

    expect(hash['foo' => 'bar']).to eql({})
  end

  it 'builds an array' do
    ast = Dry::Types['array'].member(
      Dry::Types['hash'].symbolized(
        email: Dry::Types['string'],
        age: Dry::Types['form.int'],
        admin: Dry::Types['form.bool'],
      )
    ).to_ast

    arr = compiler.(ast)

    expect(arr).to be_a(Dry::Types::Array)

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
    ast = Dry::Types['form.array'].to_ast

    arr = compiler.(ast)

    expect(arr['oops']).to eql('oops')
    expect(arr['']).to eql([])
    expect(arr[%w(a b c)]).to eql(%w(a b c))
  end

  it 'builds a safe form array with member' do
    ast = Dry::Types['form.array'].member(Dry::Types['coercible.int']).to_ast

    arr = compiler.(ast)

    expect(arr['oops']).to eql('oops')
    expect(arr[%w(1 2 3)]).to eql([1, 2, 3])
  end

  it 'builds a safe form hash' do
    ast = Dry::Types['form.hash'].symbolized(
        email: Dry::Types['string'],
        age: Dry::Types['form.int'],
        admin: Dry::Types['form.bool'],
    ).to_ast

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
    ast = Dry::Types['form.hash'].schema([]).to_ast

    type = compiler.(ast)

    expect(type[nil]).to eql({})
    expect(type[{}]).to eql({})
  end

  it 'builds a form hash from a :form_hash node' do
    ast = [:form_hash, [[], {}]]

    type = compiler.(ast)

    expect(type.fn).to be(Dry::Types['form.hash'].fn)
  end

  it 'builds a form array from a :form_array node' do
    ast = [:form_array, [[:definition, [String, {}]], {}]]

    array = compiler.(ast)

    expect(array.type.member.primitive).to be(String)
  end

  it 'builds a constructor' do
    fn = -> v { v.to_s }

    ast = Dry::Types::Constructor.new(String, &fn).to_ast

    type = compiler.(ast)

    expect(type[:foo]).to eql('foo')

    expect(type.fn).to be(fn)
    expect(type.primitive).to be(String)
  end
end
