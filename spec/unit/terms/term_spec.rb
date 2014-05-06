require "metamorpher/terms/term"
require "metamorpher/terms/literal"

module Metamorpher
  module Terms
    describe Term do
      describe "path" do
        let(:root) do
          Literal.new(
            name: :root,
            children: [
              Literal.new(
                name: :child,
                children: [
                  Term.new(name: :grandchild),
                  Term.new(name: :grandchild)
                ]
              ),
              Literal.new(
                name: :child,
                children: [
                  Term.new(name: :grandchild),
                  Term.new(name: :grandchild),
                  Term.new(name: :grandchild)
                ]
              )
            ]
          )
        end

        let(:first_child)   { root.children.first }
        let(:second_child)  { root.children.last }

        let(:leftmost_grandchild)   { first_child.children.first }
        let(:rightmost_grandchild)  { second_child.children.last }

        it "should return [] for root" do
          expect(root.path).to eq([])
        end

        it "should return [0] for first child" do
          expect(first_child.path).to eq([0])
        end

        it "should return [1] for second child" do
          expect(second_child.path).to eq([1])
        end

        it "should return [0, 0] for leftmost grandchild" do
          expect(leftmost_grandchild.path).to eq([0, 0])
        end

        it "should return [1, 2] for rightmost grandchild" do
          expect(rightmost_grandchild.path).to eq([1, 2])
        end
      end
    end
  end
end
