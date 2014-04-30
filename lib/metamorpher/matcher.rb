require "metamorpher/builders/ast"

module Metamorpher
  module Matcher
    include Builders::AST

    extend Forwardable
    def_delegator :pattern, :match, :run
  end
end
