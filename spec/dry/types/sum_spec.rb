RSpec.describe Dry::Types::Sum do
  describe 'common definition behavior' do
    subject(:type) { Dry::Types['bool'] }

    it_behaves_like 'Dry::Types::Definition#meta'

    it_behaves_like 'Dry::Types::Definition without primitive'

    it 'is frozen' do
      expect(type).to be_frozen
    end
  end

  describe '#[]' do
    it 'works with two pass-through types' do
      type = Dry::Types['int'] | Dry::Types['string']

      expect(type[312]).to be(312)
      expect(type['312']).to eql('312')
      expect(type[nil]).to be(nil)
    end

    it 'works with two strict types' do
      type = Dry::Types['strict.int'] | Dry::Types['strict.string']

      expect(type[312]).to be(312)
      expect(type['312']).to eql('312')

      expect { type[{}] }.to raise_error(TypeError)
    end

    it 'works with nil and strict types' do
      type = Dry::Types['strict.nil'] | Dry::Types['strict.string']

      expect(type[nil]).to be(nil)
      expect(type['312']).to eql('312')

      expect { type[{}] }.to raise_error(TypeError)
    end

    it 'is aliased as #call' do
      type = Dry::Types['int'] | Dry::Types['string']
      expect(type.call(312)).to be(312)
      expect(type.call('312')).to eql('312')
    end

    it 'works with two constructor & constrained types' do
      left = Dry::Types['strict.array<strict.string>']
      right = Dry::Types['strict.array<strict.hash>']

      type = left | right

      expect(type[%w(foo bar)]).to eql(%w(foo bar))

      expect(type[[{ name: 'foo' }, { name: 'bar' }]]).to eql([
        { name: 'foo' }, { name: 'bar' }
      ])
    end

    it 'works with two complex types with constraints' do
      pair = Dry::Types['strict.array']
        .member(Dry::Types['coercible.string'])
        .constrained(size: 2)

      string_list = Dry::Types['strict.array']
        .member(Dry::Types['strict.string'])
        .constrained(min_size: 1)

      string_pairs = Dry::Types['strict.array']
        .member(pair)
        .constrained(min_size: 1)

      type = string_list | string_pairs

      expect(type.(%w(foo))).to eql(%w(foo))
      expect(type.(%w(foo bar))).to eql(%w(foo bar))

      expect(type.([[1, 'foo'], [2, 'bar']])).to eql([['1', 'foo'], ['2', 'bar']])

      expect { type[:oops] }.to raise_error(Dry::Types::ConstraintError, /:oops/)

      expect { type[[]] }.to raise_error(Dry::Types::ConstraintError, /\[\]/)

      expect { type.([%i[foo]]) }.to raise_error(Dry::Types::ConstraintError, /\[:foo\]/)

      expect { type.([[1], [2]]) }.to raise_error(Dry::Types::ConstraintError, %r[[1]])
      expect { type.([[1], [2]]) }.to raise_error(Dry::Types::ConstraintError, %r[[2]])
    end
  end

  describe '#try' do
    subject(:type) { Dry::Types['strict.bool'] }

    it 'returns success when value passed' do
      expect(type.try(true)).to be_success
    end

    it 'returns failure when value did not pass' do
      expect(type.try('true')).to be_failure
    end
  end

  describe '#default' do
    it 'returns a default value sum type' do
      type = (Dry::Types['nil'] | Dry::Types['string']).default('foo')

      expect(type[nil]).to eql('foo')
    end

    it 'supports a sum type which includes a constructor type' do
      type = (Dry::Types['form.nil'] | Dry::Types['form.int']).default(3)

      expect(type['']).to be(3)
    end

    it 'supports a sum type which includes a constrained constructor type' do
      type = (Dry::Types['strict.nil'] | Dry::Types['coercible.int']).default(3)

      expect(type[nil]).to be(3)
      expect(type['3']).to be(3)
      expect(type['7']).to be(7)
    end
  end

  describe '#rule' do
    let(:two_addends) { Dry::Types['strict.nil'] | Dry::Types['strict.string'] }

    shared_examples_for 'a disjunction of constraints' do
      it 'returns a rule' do
        rule = type.rule

        expect(rule.(nil)).to be_success
        expect(rule.('1')).to be_success
        expect(rule.(1)).to be_failure
      end
    end

    it_behaves_like 'a disjunction of constraints' do
      subject(:type) { two_addends }
    end

    it_behaves_like 'a disjunction of constraints' do
      subject(:type) { Dry::Types['strict.true'] | two_addends  }

      it 'accepts true' do
        rule = type.rule

        expect(rule.(true)).to be_success
        expect(rule.(false)).to be_failure
      end
    end

    it_behaves_like 'a disjunction of constraints' do
      subject(:type) { two_addends | Dry::Types['strict.true'] }

      it 'accepts true' do
        rule = type.rule

        expect(rule.(true)).to be_success
        expect(rule.(false)).to be_failure
      end
    end
  end
end
