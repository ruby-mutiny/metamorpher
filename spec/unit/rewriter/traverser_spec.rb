require "metamorpher/rewriter/traverser"

module Metamorpher
  module Rewriter
    describe Traverser do
      describe "traversing a flat tree" do
        let(:tree) { t(1, 2, 3, 4) }

        it "correctly reports number of nodes" do
          expect(subject.traverse(tree).size).to eq(5)
        end

        it "returns nodes in left-to-right order" do
          expect(subject.traverse(tree).take(5)).to eq([tree, 1, 2, 3, 4])
        end
      end

      describe "traversing a skinny tree" do
        let(:tree) { t(1, t(2, t(3))) }

        it "correctly reports number of nodes" do
          expect(subject.traverse(tree).size).to eq(6)
        end

        it "returns nodes in outermost (root-to-leaves) order" do
          expect(subject.traverse(tree).take(6)).to eq(
            [tree, 1, tree.children.last, 2, tree.children.last.children.last, 3]
          )
        end
      end

      describe "traversing the empty tree" do
        let(:tree) { t }

        it "correctly reports number of nodes" do
          expect(subject.traverse(tree).size).to eq(1)
        end

        it "returns only the original tree" do
          expect(subject.traverse(tree).take(1)).to eq([tree])
        end
      end

      def t(*children)
        Tree.new(children)
      end

      Tree = Struct.new(:children)
    end
  end
end
