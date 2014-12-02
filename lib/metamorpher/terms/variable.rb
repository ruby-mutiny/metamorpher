require "metamorpher/terms/term"
require "metamorpher/matcher/match"

module Metamorpher
  module Terms
    class Variable < Term
      DEFAULT_CONDITION = ->(_) { true }
      attributes greedy?: false, condition: DEFAULT_CONDITION

      def inspect
        name.to_s.upcase +
          (greedy? ? "+" : "") +
          (condition != DEFAULT_CONDITION ? "?" : "")
      end
    end
  end
end
