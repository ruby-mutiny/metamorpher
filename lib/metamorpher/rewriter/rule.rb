require "attributable"
require "metamorpher/rewriter/traverser"

module Metamorpher
  module Rewriter
    class Rule
      extend Attributable
      attributes :pattern, :replacement, traverser: Traverser.new

      def apply(ast)
        rewrite_all(ast, matches_for(ast).take(1))
      end

      def reduce(ast, &block)
        rewrite_all(ast, matches_for(ast), &block)
      end

      private

      def rewrite_all(ast, matches, &block)
        matches.reduce(ast) { |a, e| rewrite(a, e, &block) }
      end

      def rewrite(ast, match, &block)
        original, rewritten = match.root, replacement.substitute(match.substitution)
        block.call(original, rewritten) if block
        ast.replace(original, rewritten)
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
