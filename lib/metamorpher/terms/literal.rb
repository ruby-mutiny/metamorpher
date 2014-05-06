require "metamorpher/terms/term"
require "metamorpher/matcher/match"
require "metamorpher/matcher/no_match"

module Metamorpher
  module Terms
    class Literal < Term
      attributes children: []

      def initialize(attributes = {})
        initialize_attributes(attributes)
        children.each { |child| child.parent = self }
      end

      def inspect
        if leaf?
          "#{name}"
        else
          "#{name}(#{children.map(&:inspect).join(', ')})"
        end
      end

      def leaf?
        children.empty?
      end

      def branch?
        !leaf?
      end

      def child_of?(parent_name)
        parent && parent.name == parent_name
      end

      def children_younger_than_or_equal_to(child)
        children[(index(child))..-1]
      end

      private

      def index(child)
        children.index(child) ||
        fail(ArgumentError, "#{child.inspect} is not a child of #{inspect}")
      end
    end
  end
end
