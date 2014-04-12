require "metamorpher/variable"

module Metamorpher
  module Builders
    class GreedyVariableBuilder
      def greedy_variable!(name, &block)
        if block
          Variable.new(name: name, condition: block, greedy?: true)
        else
          Variable.new(name: name, greedy?: true)
        end
      end

      def shorthand?(method, *arguments, &block)
        method.to_s.start_with?("_") && arguments.first == :greedy
      end

      def method_missing(method, *arguments, &block)
        if shorthand?(method, *arguments, &block)
          greedy_variable!(method[1..-1].to_sym, *arguments[1..-1], &block)
        else
          super.method_missing(method, *arguments, &block)
        end
      end
    end
  end
end
