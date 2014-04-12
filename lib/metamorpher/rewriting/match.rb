require "attributable"

module Metamorpher
  module Rewriting
    class Match
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
          Match.new(root: root, substitution: combinee.substitution.merge(substitution))
        else
          NoMatch.new
        end
      end
    end
  end
end
