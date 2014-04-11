require "metamorpher/literal"
require "metamorpher/variable"

module Metamorpher
  class TermBuilder
    def literal!(name, *children)
      Literal.new(name: name, children: children.map { |c| termify(c) })
    end

    def variable!(name, &block)
      if block
        Variable.new(name: name, condition: block)
      else
        Variable.new(name: name)
      end
    end

    def greedy_variable!(name, &block)
      if block
        Variable.new(name: name, condition: block, greedy?: true)
      else
        Variable.new(name: name, greedy?: true)
      end
    end

    def method_missing(method, *arguments, &block)
      if method.to_s.start_with?("_") && !arguments.empty? && arguments.first == :greedy
        greedy_variable!(method[1..-1].to_sym, *arguments[1..-1], &block)

      elsif method.to_s.start_with?("_")
        variable!(method[1..-1].to_sym, *arguments, &block)

      else
        literal!(method, *arguments)
      end
    end

    private

    def termify(item)
      item.kind_of?(Term) ? item : literal!(item)
    end
  end
end
