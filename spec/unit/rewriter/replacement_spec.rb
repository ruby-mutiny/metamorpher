require "metamorpher/terms/variable"
require "metamorpher/terms/derived"
require "metamorpher/terms/literal"

module Metamorpher
  module Terms
    describe Variable do
      subject { Variable.new(name: :type) }

      it "should return the replacement when the literal is the replacee" do
        replacee = Variable.new(name: :type)
        replacement = Literal.new(name: :root)

        expect(subject.replace(replacee, replacement)).to eq(replacement)
      end

      it "should return the literal when the literal is not the replacee" do
        replacee = Variable.new(name: :another_type)
        replacement = Literal.new(name: :root)

        expect(subject.replace(replacee, replacement)).to eq(subject)
      end
    end

    describe Derived do
      subject { Derived.new(base: [:type]) }

      it "should return the replacement when the literal is the replacee" do
        replacee = Derived.new(base: [:type])
        replacement = Literal.new(name: :root)

        expect(subject.replace(replacee, replacement)).to eq(replacement)
      end

      it "should return the literal when the literal is not the replacee" do
        replacee = Derived.new(base: [:another_type])
        replacement = Literal.new(name: :root)

        expect(subject.replace(replacee, replacement)).to eq(subject)
      end
    end

    describe Literal do
      describe "with no children" do
        subject { Literal.new(name: :top) }

        it "should return the replacement when the literal is the replacee" do
          replacee = Literal.new(name: :top)
          replacement = Literal.new(name: :root)

          expect(subject.replace(replacee, replacement)).to eq(replacement)
        end

        it "should return the literal when the literal is not the replacee" do
          replacee = Literal.new(name: :another)
          replacement = Literal.new(name: :root)

          expect(subject.replace(replacee, replacement)).to eq(subject)
        end
      end

      describe "with children" do
        let(:literal) do
          Literal.new(
            name: :root,
            children: [
              Literal.new(name: :child, children: [Literal.new(name: :grandchild)])
            ]
          )
        end

        let(:child) { literal.children.first }
        let(:grandchild) { child.children.first }

        it "should return the original literal with replaced descendants" do
          replacee = Literal.new(name: :grandchild)
          replacement = Literal.new(name: :new_grandchild)

          expect(literal.replace(replacee, replacement)).to eq(
            Literal.new(
              name: :root,
              children: [
                Literal.new(
                  name: :child,
                  children: [Literal.new(name: :new_grandchild)]
                )
              ]
            )
          )
        end
      end
    end
  end
end
