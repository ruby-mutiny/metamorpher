require "attributable"
require "metamorpher/visitable/visitable"
require "metamorpher/matcher/matching"
require "metamorpher/rewriter/replacement"
require "metamorpher/rewriter/substitution"

module Metamorpher
  module Terms
    class Term
      extend Attributable
      attributes :name
      attr_accessor :parent

      include Visitable
      include Matcher::Matching
      include Rewriter::Replacement
      include Rewriter::Substitution

      def inspect
        name
      end

      def with_younger_siblings
        if parent
          parent.children_younger_than_or_equal_to(self)
        else
          [self]
        end
      end
    end
  end
end
