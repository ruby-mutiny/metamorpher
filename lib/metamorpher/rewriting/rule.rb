require "attributable"
require "metamorpher/rewriting/traverser"

module Metamorpher
  module Rewriting
    class Rule
      extend Attributable
      attributes :pattern, :replacement, traverser: Traverser.new

      def apply(ast)
        rewrite(ast, find_match(ast))
      end

      private

      def rewrite(ast, match)
        ast.replace(match.root, replacement.substitute(match.substitution))
      end

      def find_match(ast)
        find_matches(ast).first
      end

      def find_matches(ast)
        traverser.traverse(ast)
          .lazy # only compute the next match when needed
          .map { |current| pattern.match(current) }
          .select { |result| result.matches? }
      end
    end
  end
end
