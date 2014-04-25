require "metamorpher/terms/literal"

module Metamorpher
  module Terms
    describe Literal do
      describe "leaf? and branch?" do
        let(:parent) { Literal.new(name: :parent, children: [Literal.new(name: :child)]) }
        let(:child)  { parent.children.first }

        it "should correctly identify childless literals as leaves not branches" do
          expect(child).to be_leaf
          expect(child).not_to be_branch
        end

        it "should correctly identify literals with children as branches not leaves" do
          expect(parent).to be_branch
          expect(parent).not_to be_leaf
        end
      end

      describe "child_of?" do
        let(:parent) { Literal.new(name: :parent, children: [Literal.new(name: :child)]) }
        let(:child)  { parent.children.first }

        # def child_of?(parent_name)
        #   parent.nil? ? false : parent.name == parent_name
        # end

        it "should return true when parent's name is parameter" do
          expect(child).to be_child_of(:parent)
        end

        it "should return false when parent's name is not parameter" do
          expect(child).not_to be_child_of(:root)
        end

        it "should false when literal has no parent" do
          expect(parent).not_to be_child_of(:root)
        end
      end

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

      describe "replace" do
        let(:replacement)  { Literal.new(name: 0) }
        let(:grandchild)   { Literal.new(name: 1) }
        let(:first_child)  { Literal.new(name: 2) }
        let(:second_child) { Literal.new(name: :inc, children: [grandchild]) }

        subject { Literal.new(name: :add, children: [first_child, second_child]) }

        it "should return replacement when replacee is subject" do
          expect(subject.replace(subject, replacement)).to eq(replacement)
        end

        it "should embed replacement when replacee is first child" do
          expect(subject.replace(first_child, replacement)).to eq(
            Literal.new(name: :add, children: [replacement, second_child])
          )
        end

        it "should embed replacement when replacee is second child" do
          expect(subject.replace(second_child, replacement)).to eq(
            Literal.new(name: :add, children: [first_child, replacement])
          )
        end

        it "should embed replacement when replacee is a nested child" do
          expect(subject.replace(grandchild, replacement)).to eq(
            Literal.new(name: :add, children: [
              first_child,
              Literal.new(name: :inc, children: [replacement])
            ])
          )
        end

        it "should return original when replacee isn't literal or a child" do
          expect(subject.replace(Literal.new(name: 42), replacement)).to eq(subject)
        end
      end
    end
  end
end
