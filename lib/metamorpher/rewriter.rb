require "metamorpher/builder"
require "metamorpher/rewriting/rule"

module Metamorpher
  module Rewriter
    extend Forwardable
    def_delegator :rule, :apply, :run

    def rule
      @rule ||= Rewriting::Rule.new(pattern: pattern, replacement: replacement)
    end

    def builder
      @builder ||= Builder.new
    end
  end
end
