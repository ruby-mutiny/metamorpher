require "metamorpher/visitable/visitor"

module Metamorpher
  module Rewriter
    module Substitution
      def substitute(substitution)
        accept SubstitutionVisitor.new(substitution)
      end
    end

    class SubstitutionVisitor < Visitable::Visitor
      attr_accessor :substitution

      def initialize(substitution)
        @substitution = substitution
      end

      def visit_variable(variable)
        substitution_for_variable(variable.name).dup
      end

      def visit_literal(literal)
        Terms::Literal.new(
          name: literal.name,
          children: literal.children.flat_map { |child| visit(child) }
        )
      end

      def visit_derived(derived)
        substitutes = derived.base.map { |v| substitution_for_variable(v) }
        derived.derivation.call(*substitutes)
      end

      def visit_termset(termset)
        Terms::TermSet.new(
          terms: termset.terms.map { |term| visit(term) }
        )
      end

      private

      def substitution_for_variable(name)
        substitution.fetch(name) do
          fail SubstitutionError, "No substitution found for variable '#{name}'"
        end
      end
    end

    class SubstitutionError < ArgumentError; end
  end
end
