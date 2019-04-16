RSpec.describe Dry::Types::Constructor::Function do
  describe '.[]' do
    shared_examples 'well-behaving coercion function' do
      it 'applies constructor' do
        expect(fun.('1')).to eql(1)
      end

      it 'rescues errors and re-throws them as coercion errors' do
        expect { fun.('a') }.to raise_error(Dry::Types::CoercionError)
      end

      it 'extends accepts a fallback block' do
        expect(fun.('a') { :fallback }).to be(:fallback)
      end
    end

    context 'proc' do
      include_examples 'well-behaving coercion function' do
        subject(:fun) { described_class[proc { |value| Integer(value) }] }

        specify { expect(fun).to be_wrapped }
      end
    end

    context 'lambda' do
      include_examples 'well-behaving coercion function' do
        subject(:fun) { described_class[lambda { |value| Integer(value) }] }

        specify { expect(fun).to be_wrapped }
      end
    end

    context 'method' do
      include_examples 'well-behaving coercion function' do
        subject(:fun) { described_class[Kernel.method(:Integer)] }

        specify { expect(fun).to be_wrapped }
      end
    end

    context 'private method' do
      include_examples 'well-behaving coercion function' do
        subject(:fun) { described_class[1.method(:Integer)] }

        specify { expect(fun).to be_wrapped }
      end
    end

    context 'method with fallback' do
      include_examples 'well-behaving coercion function' do
        subject(:fun) do
          obj = Object.new

          def obj.coerce(value, &block)
            Integer(value)
          rescue ArgumentError => error
            Dry::Types::CoercionError.handle(error, &block)
          end

          described_class[obj.method(:coerce)]
        end

        specify { expect(fun).not_to be_wrapped }
      end
    end

    context 'callable object without fallback' do
      include_examples 'well-behaving coercion function' do
        subject(:fun) do
          fn = Class.new {
            def call(value)
              Integer(value)
            end
          }.new

          described_class[fn]
        end

        specify { expect(fun).to be_wrapped }
      end
    end

    context 'callable object with fallback' do
      include_examples 'well-behaving coercion function' do
        subject(:fun) do
          fn = Class.new {
            def call(value, &block)
              Integer(value)
            rescue ArgumentError => error
              Dry::Types::CoercionError.handle(error, &block)
            end
          }.new

          described_class[fn]
        end

        specify { expect(fun).not_to be_wrapped }
      end
    end
  end

  describe '#to_ast' do
    subject(:function) { described_class[fn] }

    context 'proc' do
      let(:fn) { proc { |value| Integer(value) } }

      specify do
        expect(function.to_ast).to eql([:id, Dry::Types::FnContainer.register_name(fn)])
      end
    end

    context 'method call' do
      let(:fn) { 'foo'.method(:Integer) }

      specify do
        expect(function.to_ast).to eql([:method, 'foo', :Integer])
      end
    end

    context 'callable' do
      let(:fn) do
        Class.new {
          def call(input)
            Integer(input)
          end
        }.new
      end

      specify do
        expect(function.to_ast).to eql([:callable, fn])
      end
    end

    context 'globally accessible receiver' do
      let(:fn) { Kernel.method(:Integer) }

      specify do
        expect(function.to_ast).to eql([:method, Kernel, :Integer])
      end
    end
  end
end
