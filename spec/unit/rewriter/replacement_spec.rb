require "metamorpher/terms/variable"
require "metamorpher/terms/derived"
require "metamorpher/terms/literal"

module Metamorpher
  module Terms
    describe "replace" do
      describe "with no children" do
        subject { Literal.new(name: :top) }

        it "should be possible to replace at the top" do
          replacement = Literal.new(name: :root)

          expect(subject.replace(subject.path, replacement)).to eq(replacement)
        end
      end

      describe "with children" do
        subject do
          Literal.new(
            name: :root,
            children: [
              Literal.new(name: :first_child),
              Variable.new(name: :second_child),
              Derived.new(name: :third_child)
            ]
          )
        end

        let(:replacement) { Literal.new(name: :root) }

        it "should be possible to replace literal child" do
          expect(subject.replace(subject.children[0].path, replacement)).to eq(
            Literal.new(
              name: :root,
              children: [
                replacement,
                Variable.new(name: :second_child),
                Derived.new(name: :third_child)
              ]
            )
          )
        end

        it "should be possible to replace literal child" do
          expect(subject.replace(subject.children[1].path, replacement)).to eq(
            Literal.new(
              name: :root,
              children: [
                Literal.new(name: :first_child),
                replacement,
                Derived.new(name: :third_child)
              ]
            )
          )
        end

        it "should be possible to replace derived child" do
          expect(subject.replace(subject.children[2].path, replacement)).to eq(
            Literal.new(
              name: :root,
              children: [
                Literal.new(name: :first_child),
                Variable.new(name: :second_child),
                replacement
              ]
            )
          )
        end
      end
    end
  end
end
