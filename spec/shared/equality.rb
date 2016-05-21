shared_examples_for 'a type with equality defined' do
  it 'passes equality check' do
    expect(type).to eql(type)
    expect(type).to eq(type)
  end
end
