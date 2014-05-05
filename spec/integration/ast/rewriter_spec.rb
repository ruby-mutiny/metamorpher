require "metamorpher"
require "metamorpher/builders/ast"

describe "Rewriting" do
  let(:builder) { Metamorpher::Builders::AST::Builder.new }

  describe "literals" do
    class SuccZeroRewriter
      include Metamorpher::Rewriter
      include Metamorpher::Builders::AST

      def pattern
        builder.literal! :succ, 0
      end

      def replacement
        builder.literal! 1
      end
    end

    subject { SuccZeroRewriter.new }

    describe "with reduce" do
      it "should rewrite a matching expression" do
        expression = builder.succ(0)
        reduced = builder.literal!(1)

        expect(subject.reduce(expression)).to eq(reduced)
      end

      it "should completely rewrite all matching expressions" do
        expression = builder.add(builder.succ(0), builder.succ(0))
        reduced = builder.add(builder.literal!(1), builder.literal!(1))

        expect(subject.reduce(expression)).to eq(reduced)
      end

      it "should yield the original and replacement literals" do
        expression = builder.add(builder.succ(0), builder.succ(0))
        reduced = builder.add(builder.literal!(1), builder.literal!(1))

        expect { |b| subject.reduce(expression, &b) }.to yield_successive_args(
          [expression.children.first, reduced.children.first],
          [expression.children.last, reduced.children.last]
        )
      end

      it "should not change a non-matching expression" do
        expression = builder.succ(1)

        expect(subject.reduce(expression)).to eq(expression)
      end
    end

    describe "with apply" do
      it "should rewrite a matching expression" do
        expression = builder.succ(0)
        reduced = builder.literal!(1)

        expect(subject.apply(expression)).to eq(reduced)
      end

      it "should yield the original and replacement literal" do
        expression = builder.succ(0)
        reduced = builder.literal!(1)

        expect { |b| subject.apply(expression, &b) }.to yield_with_args(expression, reduced)
      end

      # Failing due to a bug in rewrite / replace -> all instances of replacee
      # are replaced not only the matched instance.
      # I think the solution might be to have a match capture more information
      # (e.g., about its context). For example, we might add a path attribute
      # to Match, and use a traverser to navigate the tree during matching,
      # keeping track of the path.
      xit "should rewrite only the first matching expressions" do
        expression = builder.add(builder.succ(0), builder.succ(0))
        reduced = builder.add(builder.literal!(1), builder.succ(0))

        expect(subject.apply(expression)).to eq(reduced)
      end

      it "should not change a non-matching expression" do
        expression = builder.succ(1)

        expect(subject.apply(expression)).to eq(expression)
      end
    end
  end

  describe "derivations" do
    describe "from a single variable" do
      class PluraliseRewriter
        include Metamorpher::Rewriter
        include Metamorpher::Builders::AST

        def pattern
          builder.SINGULAR
        end

        def replacement
          builder.derivation! :singular do |singular|
            builder.literal!(singular.name + "s")
          end
        end
      end

      subject { PluraliseRewriter.new }

      it "should rewrite using the derivation logic" do
        expression = builder.literal! "dog"
        reduced = builder.literal! "dogs"

        expect(subject.reduce(expression)).to eq(reduced)
      end
    end

    describe "from multiple variables" do
      class RocketRewriter
        include Metamorpher::Rewriter
        include Metamorpher::Builders::AST

        def pattern
          builder.literal!(:"=>", builder.KEY, builder.VALUE)
        end

        def replacement
          builder.derivation!(:key, :value) do |key, value|
            builder.pair(key, value)
          end
        end
      end

      subject { RocketRewriter.new }

      it "should rewrite using the derivation logic" do
        expression = builder.literal! :"=>", :foo, :bar
        reduced = builder.pair(:foo, :bar)

        expect(subject.reduce(expression)).to eq(reduced)
      end
    end
  end
end
