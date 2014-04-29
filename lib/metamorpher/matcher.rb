require "metamorpher/builders/default"

module Metamorpher
  module Matcher
    include Builders::Default

    extend Forwardable
    def_delegator :pattern, :match, :run
  end
end
