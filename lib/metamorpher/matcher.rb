module Metamorpher
  module Matcher
    extend Forwardable
    def_delegator :pattern, :match, :run
  end
end
