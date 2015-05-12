require "metamorpher/visitable/visitor"
require "metamorpher/matcher/match"
require "metamorpher/matcher/no_match"

module Metamorpher
  module Matcher
    module Matching
      def match(other)
        if other.nil?
          Matcher::NoMatch.new
        else
          accept MatchingVisitor.new(other)
        end
      end
    end

    class MatchingVisitor < Visitable::Visitor
      attr_accessor :other

      def initialize(other)
        @other = other
      end

      def visit_variable(variable)
        captured = variable.greedy? ? other.with_younger_siblings : other
        if variable.condition.call(captured)
          Matcher::Match.new(root: captured, substitution: { variable.name => captured })
        else
          Matcher::NoMatch.new
        end
      end

      def visit_literal(literal)
        if other.name == literal.name && expected_number_of_children?(literal)
          literal.children
            .zip(other.children)
            .map { |child, other_child| child.match(other_child) }
            .reduce(Matcher::Match.new(root: other), :combine)
        else
          Matcher::NoMatch.new
        end
      end

      def visit_termset(termset)
        matches = termset.terms.map { |term| term.match(other) }.select(&:matches?)
        if matches.any?
          matches.first
        else
          Matcher::NoMatch.new
        end
      end

      def visit_derived(_derived)
        fail MatchingError, "Cannot match against a derived variable."
      end

      private

      def expected_number_of_children?(literal)
        other.children.size == literal.children.size || greedy_child?(literal)
      end

      def greedy_child?(literal)
        literal.children.any? { |c| c.is_a?(Terms::Variable) && c.greedy? }
      end
    end

    class MatchingError < ArgumentError; end
  end
end
