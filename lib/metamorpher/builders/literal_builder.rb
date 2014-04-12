require "metamorpher/literal"

module Metamorpher
  module Builders
    class LiteralBuilder
      def literal!(name, *children)
        Literal.new(name: name, children: children.map { |c| termify(c) })
      end

      def shorthand?(method, *arguments, &block)
        !method.to_s.start_with?("_")
      end

      def method_missing(method, *arguments, &block)
        if shorthand?(method, *arguments, &block)
          literal!(method, *arguments)
        else
          super.method_missing(method, *arguments, &block)
        end
      end

      private

      def termify(item)
        item.kind_of?(Term) ? item : literal!(item)
      end
    end
  end
end
