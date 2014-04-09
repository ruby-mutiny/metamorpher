require "attributable"

module Metamorph
  class MatchResult
    extend Attributable
    attributes :root, substitution: {}

    def matches?
      true
    end

    def match_for(variable)
      substitution[variable.name]
    end

    def combine(combinee)
      if combinee.matches?
        MatchResult.new(root: root, substitution: combinee.substitution.merge(substitution))
      else
        NoMatchResult.new
      end
    end
  end
end
