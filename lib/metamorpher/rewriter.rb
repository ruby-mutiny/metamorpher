require "metamorpher/rule"

module Metamorpher
  module Rewriter
    extend Forwardable
    def_delegator :rule, :apply, :run

    def rule
      @rule ||= Metamorpher::Rule.new(pattern: pattern, replacement: replacement)
    end

    def builder
      @builder ||= Metamorpher::Builder.new
    end
  end
end
