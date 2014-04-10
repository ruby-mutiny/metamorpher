require "attributable"
require "metamorpher/match"

module Metamorpher
  class Variable
    extend Attributable
    attributes :name

    def inspect
      name.to_s.upcase
    end

    def match(other)
      Match.new(substitution: { name => other })
    end

    def substitute(substitution)
      substitution[name]
    end
  end
end
