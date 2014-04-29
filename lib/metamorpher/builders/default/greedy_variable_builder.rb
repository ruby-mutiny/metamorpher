require "metamorpher/terms/variable"

module Metamorpher
  module Builders
    module Default
      class GreedyVariableBuilder
        def greedy_variable!(name, &block)
          if block
            Terms::Variable.new(name: name, condition: block, greedy?: true)
          else
            Terms::Variable.new(name: name, greedy?: true)
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
end
