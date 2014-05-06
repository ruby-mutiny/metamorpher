require "metamorpher/builders/ruby/variable_replacement_visitor"

module Metamorpher
  module Builders
    module Ruby
      describe VariableReplacementVisitor do
        let(:builder) { Metamorpher::Builders::AST::Builder.new }
        let(:replacement) { builder.literal!(:bar) }
        subject { VariableReplacementVisitor.new(:foo, replacement) }

        it "should replace a variable with the correct name" do
          original = builder.variable!(:foo)
          replaced = subject.visit(original)

          expect(replaced).to eq(replacement)
        end

        it "should replace a nested variable" do
          original = builder.literal!(:+, 2, builder.variable!(:foo))
          replaced = subject.visit(original)

          expect(replaced).to eq(original.replace(original.children.last.path, replacement))
        end

        it "should not replace a variable with a different name" do
          original = builder.variable!(:bar)
          replaced = subject.visit(original)

          expect(replaced).to eq(original)
        end

        it "should not replace a literal" do
          original = builder.literal!(:foo)
          replaced = subject.visit(original)

          expect(replaced).to eq(original)
        end

        it "should not replace a derived" do
          original = builder.derivation!(:foo) {}
          replaced = subject.visit(original)

          expect(replaced).to eq(original)
        end
      end
    end
  end
end
