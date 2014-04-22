require "metamorpher/builder"
require "metamorpher/rewriting/rule"

module Metamorpher
  module Rewriter
    extend Forwardable
    def_delegators :rule, :apply, :reduce

    def rule
      @rule ||= Rewriting::Rule.new(pattern: pattern, replacement: replacement)
    end

    def builder
      @builder ||= Builder.new
    end
  end
end
