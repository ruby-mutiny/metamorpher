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

      it "should rewrite only the first matching expressions" do
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

  describe "multiple rewritings via termset" do
    class FlexiblePluraliseRewriter
      include Metamorpher::Rewriter
      include Metamorpher::Builders::AST

      def pattern
        builder.SINGULAR
      end

      def replacement
        builder.either!(
          builder.derivation!(:singular) { |singular| builder.literal!(singular.name + "s") },
          builder.derivation!(:singular) { |singular| builder.literal!(singular.name + "es") }
        )
      end
    end

    subject { FlexiblePluraliseRewriter.new }

    it "should rewrite using each derivation" do
      expression = builder.literal! "virus"
      reduced = builder.either!(builder.literal!("viruss"), builder.literal!("viruses"))

      expect(subject.reduce(expression)).to eq(reduced)
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

    describe "from entire value" do
      class Inverter
        include Metamorpher::Rewriter
        include Metamorpher::Builders::AST

        def pattern
          builder.true
        end

        def replacement
          builder.derivation!(:&) do |matched|
            builder.literal!(:not, matched)
          end
        end
      end

      subject { Inverter.new }

      it "should rewrite yielding the entire match to the derivation logic" do
        expression = builder.literal! :true
        reduced = builder.literal!(:not, :true)

        expect(subject.reduce(expression)).to eq(reduced)
      end
    end

    describe "to several alternatives" do
      class FlexiblePluraliseRewriterInner
        include Metamorpher::Rewriter
        include Metamorpher::Builders::AST

        def pattern
          builder.SINGULAR
        end

        def replacement
          builder.derivation!(:singular) do |singular|
            builder.either!(
              builder.literal!(singular.name + "s"),
              builder.literal!(singular.name + "es")
            )
          end
        end
      end

      subject { FlexiblePluraliseRewriterInner.new }

      it "should rewrite using each derivation" do
        expression = builder.literal! "virus"
        reduced = builder.either!(builder.literal!("viruss"), builder.literal!("viruses"))

        expect(subject.reduce(expression)).to eq(reduced)
      end
    end

    describe "using implicit derivation" do
      class KeyExtractor
        include Metamorpher::Rewriter
        include Metamorpher::Builders::AST

        def pattern
          builder.literal!(:"=>", builder.KEY, builder.VALUE)
        end

        def replacement
          builder.derivation!(:key)
        end
      end

      subject { KeyExtractor.new }

      it "should rewrite using the implicit derivation" do
        expression = builder.literal! :"=>", :foo, :bar
        reduced = builder.literal! :foo

        expect(subject.reduce(expression)).to eq(reduced)
      end
    end
  end
end
