require "attributable"

module Metamorph
  class NoMatchResult
    def matches?
      false
    end

    def combine(_)
      NoMatchResult.new
    end
  end
end
