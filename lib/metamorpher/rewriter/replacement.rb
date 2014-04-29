require "metamorpher/visitable/visitor"

module Metamorpher
  module Rewriter
    module Replacement
      def replace(replacee, replacement)
        accept ReplacementVisitor.new(replacee, replacement)
      end
    end

    class ReplacementVisitor < Visitable::Visitor
      attr_accessor :replacee, :replacement

      def initialize(replacee, replacement)
        @replacee, @replacement = replacee, replacement
      end

      def visit_literal(literal)
        if literal == replacee
          replacement
        else
          Terms::Literal.new(
            name: literal.name,
            children: literal.children.map { |child| visit(child) }
          )
        end
      end

      def visit_term(term)
        if term == replacee
          replacement
        else
          term
        end
      end
    end

    class ReplacementError < ArgumentError; end
  end
end
