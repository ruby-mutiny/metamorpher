require "metamorpher/variable"

module Metamorpher
  module Builders
    class VariableBuilder
      def variable!(name, &block)
        if block
          Variable.new(name: name, condition: block)
        else
          Variable.new(name: name)
        end
      end

      def shorthand?(method, *arguments, &block)
        method.to_s.start_with?("_") && arguments.first != :greedy
      end

      def method_missing(method, *arguments, &block)
        if shorthand?(method, *arguments, &block)
          variable!(method[1..-1].to_sym, *arguments, &block)
        else
          super.method_missing(method, *arguments, &block)
        end
      end
    end
  end
end