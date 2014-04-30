require "metamorpher/terms/literal"

module Metamorpher
  module Builders
    module AST
      class LiteralBuilder
        def literal!(name, *children)
          Terms::Literal.new(name: name, children: children.map { |c| termify(c) })
        end

        def shorthand?(method, *arguments, &block)
          method =~ /^[a-z]/
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
          item.kind_of?(Terms::Term) ? item : literal!(item)
        end
      end
    end
  end
end
