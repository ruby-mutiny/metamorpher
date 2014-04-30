require "metamorpher/builders/ast/builder"

module Metamorpher
  module Builders
    module AST
      def builder
        @builder ||= Builder.new
      end
    end
  end
end
