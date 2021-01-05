# frozen_string_literal: true

RSpec.describe Dry::Types::Constructor::Function do
  describe ".[]" do
    shared_examples "well-behaving coercion function" do
      it "applies constructor" do
        expect(fun.("1")).to eql(1)
      end

      it "rescues errors and re-throws them as coercion errors" do
        expect { fun.("a") }.to raise_error(Dry::Types::CoercionError)
      end

      it "extends accepts a fallback block" do
        expect(fun.("a") { :fallback }).to be(:fallback)
      end
    end

    context "proc" do
      include_examples "well-behaving coercion function" do
        subject(:fun) { described_class[proc { |value| Integer(value) }] }
      end
    end

    context "lambda" do
      include_examples "well-behaving coercion function" do
        subject(:fun) { described_class[->(value) { Integer(value) }] }
      end
    end

    context "method" do
      include_examples "well-behaving coercion function" do
        subject(:fun) { described_class[Kernel.method(:Integer)] }
      end
    end

    context "private method" do
      include_examples "well-behaving coercion function" do
        subject(:fun) { described_class[1.method(:Integer)] }
      end
    end

    context "method with fallback" do
      let(:obj) do
        obj = Object.new

        def obj.coerce(value, &block)
          Integer(value)
        rescue ArgumentError => e
          Dry::Types::CoercionError.handle(e, &block)
        end

        obj
      end

      subject(:fun) do
        described_class[obj.method(:coerce)]
      end

      include_examples "well-behaving coercion function"

      context "private method" do
        before do
          obj.singleton_class.send(:private, :coerce)
        end

        include_examples "well-behaving coercion function"
      end
    end

    context "callable object without fallback" do
      include_examples "well-behaving coercion function" do
        subject(:fun) do
          fn = Class.new {
            def call(value)
              Integer(value)
            end
          }.new

          described_class[fn]
        end
      end
    end

    context "callable object with fallback" do
      include_examples "well-behaving coercion function" do
        subject(:fun) do
          fn = Class.new {
            def call(value, &block)
              Integer(value)
            rescue ArgumentError => e
              Dry::Types::CoercionError.handle(e, &block)
            end
          }.new

          described_class[fn]
        end
      end
    end
  end

  describe "#to_ast" do
    subject(:function) { described_class[fn] }

    context "proc" do
      let(:fn) { proc { |value| Integer(value) } }

      specify do
        expect(function.to_ast).to eql([:id, Dry::Types::FnContainer.register_name(fn)])
      end
    end

    context "method call" do
      let(:fn) { "foo".method(:Integer) }

      specify do
        expect(function.to_ast).to eql([:method, "foo", :Integer])
      end
    end

    context "callable" do
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

    context "globally accessible receiver" do
      let(:fn) { Kernel.method(:Integer) }

      specify do
        expect(function.to_ast).to eql([:method, Kernel, :Integer])
      end
    end
  end

  describe "#>>" do
    let(:power_2) { described_class[-> x { x**2 }] }

    let(:mult_2) { described_class[-> x { x + 1 }] }

    subject(:comp_a) { power_2 >> mult_2 }
    subject(:comp_b) { mult_2 >> power_2 }

    it "composes two functions" do
      expect(comp_a.(3)).to eql(10)
      expect(comp_b.(3)).to eql(16)
    end
  end

  describe "#<<" do
    let(:power_2) { described_class[-> x { x**2 }] }

    let(:mult_2) { described_class[-> x { x + 1 }] }

    subject(:comp_a) { power_2 << mult_2 }
    subject(:comp_b) { mult_2 << power_2 }

    it "composes two functions" do
      expect(comp_a.(3)).to eql(16)
      expect(comp_b.(3)).to eql(10)
    end
  end
end
