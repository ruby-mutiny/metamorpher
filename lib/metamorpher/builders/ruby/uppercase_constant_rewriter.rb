require "metamorpher/builders/ast"
require "metamorpher/builders/ruby/uppercase_rewriter"

module Metamorpher
  module Builders
    module Ruby
      class UppercaseConstantRewriter < UppercaseRewriter
        include Metamorpher::Rewriter
        include Metamorpher::Builders::AST

        def pattern
          builder.const(builder.literal!(nil), super)
        end
      end
    end
  end
end
