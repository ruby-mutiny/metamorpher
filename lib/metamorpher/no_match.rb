require "attributable"

module Metamorpher
  class NoMatch
    def matches?
      false
    end

    def combine(_)
      NoMatch.new
    end
  end
end
