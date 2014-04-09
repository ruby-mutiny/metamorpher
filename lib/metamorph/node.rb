require "attributable"
require "metamorph/match_result"
require "metamorph/no_match_result"

module Metamorph
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
        NoMatchResult.new
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
        .reduce(MatchResult.new(root: other), :combine)
    end
  end
end
