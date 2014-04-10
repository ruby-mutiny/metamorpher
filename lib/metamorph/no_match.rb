require "attributable"

module Metamorph
  class NoMatch
    def matches?
      false
    end

    def combine(_)
      NoMatch.new
    end
  end
end
