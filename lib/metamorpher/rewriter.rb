require "metamorpher/builders/ast"
require "metamorpher/rewriter/rule"

module Metamorpher
  module Rewriter
    include Builders::AST

    extend Forwardable
    def_delegators :rule, :apply, :reduce

    def rule
      @rule ||= Rewriter::Rule.new(pattern: pattern, replacement: replacement)
    end
  end
end
