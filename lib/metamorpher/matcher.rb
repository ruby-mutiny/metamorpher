require "metamorpher/builder"

module Metamorpher
  module Matcher
    extend Forwardable
    def_delegator :pattern, :match, :run

    def builder
      @builder ||= Builder.new
    end
  end
end
