require "metamorpher/rewriting/term"
require "metamorpher/matching/match"

module Metamorpher
  module Rewriting
    class Variable < Term
      attributes greedy?: false, condition: ->(_) { true }

      def inspect
        name.to_s.upcase
      end

      def substitute(substitution)
        substitution[name]
      end

      def match(other)
        captured = capture(other)
        if condition.call(captured)
          Matching::Match.new(root: captured, substitution: { name => captured })
        else
          Matching::NoMatch.new
        end
      end

      def capture(other)
        greedy? ? other.and_younger_siblings : other
      end
    end
  end
end
