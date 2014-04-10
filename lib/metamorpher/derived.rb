require "attributable"

module Metamorpher
  class Derived
    extend Attributable
    attributes :base, :derivation
    attr_accessor :parent

    def inspect
      name.to_s.upcase
    end

    def substitute(substitution)
      substitutes = substitution.values_at(*base)
      derivation.call(*substitutes)
    end
  end
end
