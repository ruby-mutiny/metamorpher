require "metamorpher/rewriting/literal"

module Metamorpher
  module Rewriting
    describe Literal do
      describe "children younger than or equal to" do
        let(:eldest)   { Term.new(name: :eldest) }
        let(:middle)   { Term.new(name: :middle) }
        let(:youngest) { Term.new(name: :youngest) }

        subject { Literal.new(name: :parent, children: [eldest, middle, youngest]) }

        it "should return all children not to the 'left' of argument" do
          expect(subject.children_younger_than_or_equal_to(middle)).to eq([middle, youngest])
        end

        it "should return an only argument when argument is the youngest" do
          expect(subject.children_younger_than_or_equal_to(youngest)).to eq([youngest])
        end

        it "should raise when argument is not a child" do
          expect { subject.children_younger_than_or_equal_to(Term.new(name: :unknown)) }
            .to raise_error(ArgumentError)
        end
      end
    end
  end
end
