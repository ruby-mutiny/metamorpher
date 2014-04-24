module Metamorpher
  module Rewriter
    class Traverser
      def traverse(tree)
        Enumerator.new(count(tree)) do |yielder|
          waiting = [tree]
          until waiting.empty?
            current = waiting.shift
            yielder << current
            waiting.concat(children(current))
          end
        end
      end

      private

      def count(tree)
        children(tree).flat_map { |child| count(child) }.inject(1, :+)
      end

      def children(node)
        node.respond_to?(:children) ? node.children : []
      end
    end
  end
end
