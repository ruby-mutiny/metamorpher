require "metamorpher/builders/ruby/variable_replacement_visitor"

module Metamorpher
  module Builders
    module Ruby
      class EnsuringVisitor < VariableReplacementVisitor
        def initialize(variable_name, condition)
          super(variable_name, Terms::Variable.new(name: variable_name, condition: condition))
        end
      end
    end
  end
end
