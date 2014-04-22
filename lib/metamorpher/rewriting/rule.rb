require "attributable"
require "metamorpher/rewriting/traverser"

module Metamorpher
  module Rewriting
    class Rule
      extend Attributable
      attributes :pattern, :replacement, traverser: Traverser.new

      def apply(ast)
        rewrite_all(ast, matches_for(ast).take(1))
      end

      def reduce(ast)
        rewrite_all(ast, matches_for(ast))
      end

      private

      def rewrite_all(ast, matches)
        matches.reduce(ast) { |a, e| rewrite(a, e) }
      end

      def rewrite(ast, match)
        ast.replace(match.root, replacement.substitute(match.substitution))
      end

      def matches_for(ast)
        traverser.traverse(ast)
          .lazy # only compute the next match when needed
          .map { |current| pattern.match(current) }
          .select { |result| result.matches? }
      end
    end
  end
end
