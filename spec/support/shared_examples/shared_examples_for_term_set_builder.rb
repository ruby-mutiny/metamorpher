require "metamorpher/terms/term_set"
require "metamorpher/terms/literal"
require "metamorpher/terms/variable"

module Metamorpher
  module Terms
    shared_examples_for "a term set builder" do
      describe "either!" do
        it "should create an instance of TermSet" do
          actual = subject.either!(Literal.new(name: :a), Variable.new(name: :b))
          expected = TermSet.new(terms: [Literal.new(name: :a), Variable.new(name: :b)])

          expect(actual).to eq(expected)
        end

        it "should return an empty TermSet when given no arguments" do
          actual = subject.either!
          expected = Metamorpher::Terms::TermSet.new

          expect(actual).to eq(expected)
        end

        it "should automatically convert arguments to literals" do
          actual = subject.either!(:add, :subtract)
          expected = TermSet.new(terms: [Literal.new(name: :add), Literal.new(name: :subtract)])

          expect(actual).to eq(expected)
        end

        it "should not automatically convert arguments that are already terms" do
          actual = subject.either!(:add, Variable.new(name: :operator))
          expected = TermSet.new(terms: [Literal.new(name: :add), Variable.new(name: :operator)])

          expect(actual).to eq(expected)
        end
      end
    end
  end
end
