require "metamorpher/terms/variable"

module Metamorpher
  module Builders
    module AST
      class VariableBuilder
        def variable!(name, &block)
          if block
            Terms::Variable.new(name: name, condition: block)
          else
            Terms::Variable.new(name: name)
          end
        end

        def shorthand?(method, *arguments, &block)
          !method[/\p{Lower}/] && !method.to_s.end_with?("_")
        end

        def method_missing(method, *arguments, &block)
          if shorthand?(method, *arguments, &block)
            variable!(method.downcase.to_sym, *arguments, &block)
          else
            super.method_missing(method, *arguments, &block)
          end
        end
      end
    end
  end
end
