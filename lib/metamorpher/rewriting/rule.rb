require "attributable"
require "metamorpher/rewriting/traverser"

module Metamorpher
  module Rewriting
    class Rule
      extend Attributable
      attributes :pattern, :replacement, traverser: Traverser.new

      def apply(ast)
        result = match(ast)

        if ast == result.root
          replacement.substitute(result.substitution)
        else
          ast.replace(result.root, replacement.substitute(result.substitution))
        end
      end

      private

      def match(ast)
        matches(ast).first
      end

      def matches(ast)
        traverser.traverse(ast)
          .lazy # only compute the next match when needed
          .map { |current| pattern.match(current) }
          .select { |result| result.matches? }
      end
    end
  end
end
