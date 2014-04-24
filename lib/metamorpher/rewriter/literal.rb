require "metamorpher/rewriter/term"
require "metamorpher/matcher/match"
require "metamorpher/matcher/no_match"

module Metamorpher
  module Rewriter
    class Literal < Term
      attributes children: []

      def initialize(attributes = {})
        initialize_attributes(attributes)
        children.each { |child| child.parent = self }
      end

      def inspect
        if children.empty?
          "#{name}"
        else
          "#{name}(#{children.map(&:inspect).join(', ')})"
        end
      end

      def children_younger_than_or_equal_to(child)
        children[(index(child))..-1]
      end

      def match(other)
        if other && other.name == name
          children
            .zip(other.children)
            .map { |child, other_child| child.match(other_child) }
            .reduce(Matcher::Match.new(root: other), :combine)
        else
          Matcher::NoMatch.new
        end
      end

      def substitute(substitution)
        Literal.new(
          name: name,
          children: children.map { |child| child.substitute(substitution) }
        )
      end

      def replace(replacee, replacement)
        if self == replacee
          replacement
        else
          Literal.new(
            name: name,
            children: children.map { |child| child.replace(replacee, replacement) }
          )
        end
      end

      private

      def index(child)
        children.index(child) ||
        fail(ArgumentError, "#{child.inspect} is not a child of #{inspect}")
      end
    end
  end
end
