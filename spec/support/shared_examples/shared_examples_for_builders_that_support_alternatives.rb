require "metamorpher/terms/term_set"
require "metamorpher/terms/literal"
require "metamorpher/terms/variable"

module Metamorpher
  module Terms
    shared_examples_for "a builder that supports alternatives" do
      describe "either!" do
        it "should create an instance of TermSet" do
          actual = subject.either!(subject.literal!(:a), subject.variable!(:b))
          expected = TermSet.new(terms: [Literal.new(name: :a), Variable.new(name: :b)])

          expect(actual).to eq(expected)
        end

        it "should return an empty TermSet when given no arguments" do
          actual = subject.either!
          expected = Metamorpher::Terms::TermSet.new

          expect(actual).to eq(expected)
        end
      end
    end
  end
end
