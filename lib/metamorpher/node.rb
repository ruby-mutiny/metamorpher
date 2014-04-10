require "attributable"
require "metamorpher/match"
require "metamorpher/no_match"

module Metamorpher
  class Node
    extend Attributable
    attributes :type, children: []

    def inspect
      if children.empty?
        "#{type}"
      else
        "#{type}(#{children.map(&:inspect).join(', ')})"
      end
    end

    def match(other)
      if type == other.type
        children_match(other)
      else
        NoMatch.new
      end
    end

    def substitute(substitution)
      Node.new(
        type: type,
        children: children.map { |child| child.substitute(substitution) }
      )
    end

    def replace(child, replacement)
      Node.new(
        type: type,
        children: children.map { |original| original == child ? replacement : original }
      )
    end

    private

    def children_match(other)
      children
        .zip(other.children)
        .map { |child, other_child| child.match(other_child) }
        .reduce(Match.new(root: other), :combine)
    end
  end
end
