require "metamorpher/node"
require "metamorpher/match"

module Metamorpher
  class Variable < Node
    attributes condition: ->(_) { true }

    def inspect
      name.to_s.upcase
    end

    def substitute(substitution)
      substitution[name]
    end

    def match(other)
      captured = capture(other)
      if condition.call(captured)
        Match.new(substitution: { name => captured })
      else
        NoMatch.new
      end
    end

    def capture(other)
      other
    end
  end
end
