require "metamorpher/term"

module Metamorpher
  class Derived < Term
    attributes :base, :derivation

    def substitute(substitution)
      substitutes = substitution.values_at(*base)
      derivation.call(*substitutes)
    end
  end
end
