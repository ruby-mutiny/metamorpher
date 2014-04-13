require "attributable"

module Metamorpher
  module Rewriting
    class Term
      extend Attributable
      attributes :name

      attr_accessor :parent

      def inspect
        name
      end

      def with_younger_siblings
        parent.children_younger_than_or_equal_to(self)
      end
    end
  end
end
