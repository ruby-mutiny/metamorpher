require "metamorpher/terms/literal"

module Metamorpher
  module Builders
    module AST
      class LiteralBuilder
        def literal!(name, *children)
          Terms::Literal.new(name: name, children: children.map(&method(:termify)))
        end

        def shorthand?(method, *_arguments, &_block)
          !method[/\p{Upper}/]
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
          item.is_a?(Terms::Term) ? item.dup : literal!(item)
        end
      end
    end
  end
end
