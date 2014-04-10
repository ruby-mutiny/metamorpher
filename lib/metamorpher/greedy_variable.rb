require "metamorpher/variable"
require "metamorpher/match"

module Metamorpher
  class GreedyVariable < Variable
    specialises Variable

    def capture(other)
      other.and_younger_siblings
    end
  end
end
