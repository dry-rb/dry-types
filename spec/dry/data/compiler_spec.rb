require 'dry/data/compiler'

RSpec.describe Dry::Data::Compiler, '#call' do
  subject(:compiler) { Dry::Data::Compiler.new(Dry::Data) }

  it 'builds a typed hash' do
    ast = [
      :type, [
        'hash', [
          [:key, [:email, 'string']],
          [:key, [:age, 'form.int']],
          [:key, [:admin, 'form.bool']]
        ]
      ]
    ]

    hash = compiler.(ast)

    expect(hash).to be_instance_of(Dry::Data::Type::Hash)

    expect(hash[email: 'jane@doe.org', age: '20', admin: '1']).to eql(
      email: 'jane@doe.org', age: 20, admin: true
    )
  end
end
