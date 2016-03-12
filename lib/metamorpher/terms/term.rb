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

      def alternatives
        [self]
      end

      def path
        if parent
          parent.path << parent.children.index { |c| c.equal?(self) }
        else
          []
        end
      end

      def with_younger_siblings
        if parent
          parent.children_younger_than_or_equal_to(self)
        else
          [self]
        end
      end

      def debug_print
        root = self
        root = root.parent while root.parent

        debug_print_element(root)
        puts "---"
      end

      def debug_print_element(current, depth = 0)
        output = " " * depth
        output += "#{current.name} (#{current.hash})"
        output += " <---" if current == self
        puts output
        return if visited_elements.include?(current)
        visited_elements << current

        if respond_to? :children
          children.each do |child|
            debug_print_element(child, depth + 2)
          end
        end
      end

      def visited_elements
        @visited_elements ||= []
      end
    end
  end
end
