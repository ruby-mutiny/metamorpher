require "metamorpher/terms/literal"
require "metamorpher/terms/variable"

module Metamorpher
  module Terms
    shared_examples_for "a literal builder" do
      describe "literal!" do
        it "should create an instance of Literal" do
          actual = subject.literal!(:a)
          expected = Literal.new(name: :a)

          expect(actual).to eq(expected)
        end

        it "should work with numeric names" do
          actual = subject.literal!(4)
          expected = Literal.new(name: 4)

          expect(actual).to eq(expected)
        end

        it "should capture single children" do
          actual = subject.literal!(:inc, subject.literal!(1))
          expected = Literal.new(name: :inc, children: [Literal.new(name: 1)])

          expect(actual).to eq(expected)
        end

        it "should capture several children" do
          actual = subject.literal!(:add, subject.literal!(1), subject.literal!(2))
          expected = Literal.new(
            name: :add,
            children: [
              Literal.new(name: 1),
              Literal.new(name: 2)
            ]
          )

          expect(actual).to eq(expected)
        end

        it "should automatically convert children to literals" do
          actual = subject.literal!(:add, 1, 2)
          expected = Literal.new(
            name: :add,
            children: [
              Literal.new(name: 1),
              Literal.new(name: 2)
            ]
          )

          expect(actual).to eq(expected)
        end

        it "should not automatically convert children that are already terms" do
          actual = subject.literal!(:inc, Variable.new(name: :a))
          expected = Literal.new(name: :inc, children: [Variable.new(name: :a)])

          expect(actual).to eq(expected)
        end
      end

      describe "literal shorthand" do
        it "should create an instance of Literal" do
          actual = subject.a
          expected = Literal.new(name: :a)

          expect(actual).to eq(expected)
        end

        it "should capture children" do
          actual = subject.add(1, 2)
          expected = Literal.new(
            name: :add,
            children: [
              Literal.new(name: 1),
              Literal.new(name: 2)
            ]
          )

          expect(actual).to eq(expected)
        end

        it "should raise when incorrect shorthand is used" do
          expect { subject.INC }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
