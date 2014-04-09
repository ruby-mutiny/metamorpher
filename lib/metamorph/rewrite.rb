require "attributable"

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

  class Variable
    extend Attributable
    attributes :name

    def inspect
      name.to_s.upcase
    end

    def match(other)
      MatchResult.new(substitution: { name => other })
    end

    def substitute(substitution)
      substitution[name]
    end
  end

  class NoMatchResult
    def matches?
      false
    end

    def combine(_)
      NoMatchResult.new
    end
  end

  class MatchResult
    extend Attributable
    attributes :root, substitution: {}

    def matches?
      true
    end

    def match_for(variable)
      substitution[variable.name]
    end

    def combine(combinee)
      if combinee.matches?
        MatchResult.new(root: root, substitution: combinee.substitution.merge(substitution))
      else
        NoMatchResult.new
      end
    end
  end

  class Rule
    extend Attributable
    attributes :pattern, :replacement

    def apply(ast)
      result = match(ast)

      if ast == result.root
        replacement.substitute(result.substitution)
      else
        ast.replace(result.root, replacement.substitute(result.substitution))
      end
    end

    private

    def match(ast)
      waiting, discovered, result = [ast], [], nil
      loop do
        current = waiting.pop
        unless discovered.include?(current)
          discovered << current
          waiting.concat(current.children)
        end
        result = pattern.match(current)
        return result if result.matches?
      end
    end
  end
end
