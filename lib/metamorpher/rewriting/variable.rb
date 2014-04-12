require "metamorpher/rewriting/term"
require "metamorpher/rewriting/match"

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
          Match.new(substitution: { name => captured })
        else
          NoMatch.new
        end
      end

      def capture(other)
        greedy? ? other.and_younger_siblings : other
      end
    end
  end
end
