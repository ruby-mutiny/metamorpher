require "metamorpher/terms/term_set"
require "metamorpher/terms/literal"

module Metamorpher
  module Builders
    module AST
      class TermSetBuilder
        def either!(*terms)
          Terms::TermSet.new(terms: terms.map(&method(:termify)))
        end

        private

        def termify(item)
          item.is_a?(Terms::Term) ? item : Terms::Literal.new(name: item)
        end
      end
    end
  end
end
