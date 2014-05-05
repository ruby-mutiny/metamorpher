module Metamorpher
  module Builders
    module Ruby
      class VariableReplacementVisitor < Visitable::Visitor
        attr_accessor :variable_name, :replacement

        def initialize(variable_name, replacement)
          @variable_name, @replacement = variable_name, replacement
        end

        def visit_literal(literal)
          Terms::Literal.new(
            name: literal.name,
            children: literal.children.map { |child| visit(child) }
          )
        end

        def visit_variable(variable)
          if variable.name == variable_name
            replacement
          else
            variable
          end
        end

        def visit_term(term)
          term
        end
      end
    end
  end
end
