require "attributable"
require "metamorph/match_result"

module Metamorph
  class Variable
    extend Attributable
    attributes :name

    def inspect
      name.to_s.upcase
    end

    def match(other)
      MatchResult.new(substitution: { name => other })
    end

    def substitute(substitution)
      substitution[name]
    end
  end
end
