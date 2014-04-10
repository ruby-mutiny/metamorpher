require "metamorpher/node"

module Metamorpher
  class Derived < Node
    attributes :base, :derivation

    def substitute(substitution)
      substitutes = substitution.values_at(*base)
      derivation.call(*substitutes)
    end
  end
end
