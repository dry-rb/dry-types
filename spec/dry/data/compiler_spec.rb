require 'dry/data/compiler'

RSpec.describe Dry::Data::Compiler, '#call' do
  subject(:compiler) { Dry::Data::Compiler.new(Dry::Data) }

  it 'builds a typed strict hash' do
    ast = [
      :type, [
        'hash', [
          :strict, [
            [:key, [:email, 'string']],
            [:key, [:age, 'form.int']],
            [:key, [:admin, 'form.bool']]
          ]
        ]
      ]
    ]

    hash = compiler.(ast)

    expect(hash).to be_instance_of(Dry::Data::Type::Hash)

    expect(hash[email: 'jane@doe.org', age: '20', admin: '1']).to eql(
      email: 'jane@doe.org', age: 20, admin: true
    )

    expect { hash[foo: 'jane@doe.org', age: '20', admin: '1'] }.to raise_error(
      Dry::Data::SchemaKeyError, /email/
    )
  end

  it 'builds a typed safe hash' do
    ast = [
      :type, [
        'hash', [
          :schema, [
            [:key, [:email, 'string']],
            [:key, [:age, 'form.int']],
            [:key, [:admin, 'form.bool']]
          ]
        ]
      ]
    ]

    hash = compiler.(ast)

    expect(hash).to be_instance_of(Dry::Data::Type::Hash)

    expect(hash[foo: 'bar', email: 'jane@doe.org', age: '20', admin: '1']).to eql(
      email: 'jane@doe.org', age: 20, admin: true
    )
  end
end
