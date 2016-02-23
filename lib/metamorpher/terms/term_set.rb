require "metamorpher/terms/term"

module Metamorpher
  module Terms
    class TermSet < Term
      attributes terms: []

      def initialize(attributes = {})
        initialize_attributes(attributes)
        terms.each { |term| term.parent = self }
      end

      def inspect
        "TermSet" + terms.inspect
      end

      def alternatives
        terms
      end

      def children
        terms
      end
    end
  end
end
