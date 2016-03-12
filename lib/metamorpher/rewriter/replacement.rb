module Metamorpher
  module Rewriter
    module Replacement
      def replace(path, replacement)
        if path.empty?
          replacement.dup
        else
          Terms::Literal.new(
            name: name,
            children: children.map_at(path.first) { |e| e.replace(path.drop(1), replacement) }
          )
        end
      end
    end

    class ReplacementError < ArgumentError; end
  end
end
