require "metamorpher/rewriter/term"

module Metamorpher
  module Rewriter
    class Derived < Term
      attributes :base, :derivation

      def inspect
        "[#{base.map(&:upcase).join(", ")}] -> ..."
      end

      def substitute(substitution)
        substitutes = substitution.values_at(*base)
        derivation.call(*substitutes)
      end
    end
  end
end
