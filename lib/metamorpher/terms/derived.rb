require "metamorpher/terms/term"

module Metamorpher
  module Terms
    class Derived < Term
      attributes :base, :derivation

      def inspect
        "[#{base.map(&:upcase).join(', ')}] -> ..."
      end
    end
  end
end
