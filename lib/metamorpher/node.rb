require "attributable"

module Metamorpher
  class Node
    extend Attributable
    attributes :name

    attr_accessor :parent

    def younger_siblings
      parent.children[parent.children.index(self) + 1..-1]
    end

    def and_younger_siblings
      younger_siblings.unshift(self)
    end
  end
end
