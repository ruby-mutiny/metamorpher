require "metamorpher"
require "metamorpher/rewriter"

module Metamorpher
  class SimpleRewriter
    include Rewriter

    def pattern
      builder.succ 0
    end

    def replacement
      builder.literal! 1
    end
  end

  describe SimpleRewriter do
    let(:builder) { Metamorpher.builder }

    describe "for reducible expressions" do
      let(:original) { builder.add(builder.succ(0), builder.succ(0)) }

      it "reduce should completely rewrite expression" do
        expect(subject.reduce(original)).to eq(builder.add(1, 1))
      end

      it "reduce should yield the original and replacement literals" do
        expect { |b| subject.reduce(original, &b) }.to yield_successive_args(
          [original.children.first, subject.replacement],
          [original.children.last, subject.replacement]
        )
      end

      # Failing due to a bug in rewrite / replace -> all instances of replacee
      # are replaced not only the matched instance.
      # I think the solution might be to have a match capture more information
      # (e.g., about its context). For example, we might add a path attribute
      # to Match, and use a traverser to navigate the tree during matching,
      # keeping track of the path.
      xit "apply should only reduce expression once" do
        expect(subject.apply(original)).to eq(builder.add(1, builder.succ(0)))
      end
    end

    describe "for expressions that do not match" do
      let(:irreducible) { builder.add(builder.succ(1), builder.succ(1)) }

      it "reduce should not change the expression" do
        expect(subject.reduce(irreducible)).to eq(irreducible)
      end

      it "apply should not change the expression" do
        expect(subject.apply(irreducible)).to eq(irreducible)
      end
    end
  end
end
