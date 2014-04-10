require "attributable"
require "metamorpher/match"

module Metamorpher
  class GreedyVariable
    extend Attributable
    attributes :name, condition: ->(_) { true }
    attr_accessor :parent

    def inspect
      name.to_s.upcase
    end

    def match(other)
      if condition.call(other.and_younger_siblings)
        Match.new(substitution: { name => other.and_younger_siblings })
      else
        NoMatch.new
      end
    end

    def substitute(substitution)
      substitution[name]
    end
  end
end
