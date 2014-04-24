require "metamorpher/rewriter/term"
require "metamorpher/matcher/match"

module Metamorpher
  module Rewriter
    class Variable < Term
      DEFAULT_CONDITION = ->(_) { true }
      attributes greedy?: false, condition: DEFAULT_CONDITION

      def inspect
        name.to_s.upcase +
        (greedy? ? "+" : "") +
        (condition != DEFAULT_CONDITION ? "?" : "")
      end

      def substitute(substitution)
        substitution[name]
      end

      def match(other)
        captured = capture(other)
        if condition.call(captured)
          Matcher::Match.new(root: captured, substitution: { name => captured })
        else
          Matcher::NoMatch.new
        end
      end

      def capture(other)
        greedy? ? other.with_younger_siblings : other
      end
    end
  end
end
