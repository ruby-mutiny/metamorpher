require "metamorpher/terms/term"

module Metamorpher
  module Terms
    class TermSet < Term
      attributes terms: []

      def inspect
        "TermSet" + terms.inspect
      end
    end
  end
end
