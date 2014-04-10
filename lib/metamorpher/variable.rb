require "attributable"
require "metamorpher/match"

module Metamorpher
  class Variable
    extend Attributable
    attributes :name, condition: ->(_) { true }
    attr_accessor :parent

    def inspect
      name.to_s.upcase
    end

    def match(other)
      if condition.call(other)
        Match.new(substitution: { name => other })
      else
        NoMatch.new
      end
    end

    def substitute(substitution)
      substitution[name]
    end
  end
end
