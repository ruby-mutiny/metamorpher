require "metamorpher/terms/term"

module Metamorpher
  module Terms
    class TermSet < Term
      attributes terms: []

      def inspect
        "TermSet" + terms.inspect
      end

      def alternatives
        terms
      end
    end
  end
end
