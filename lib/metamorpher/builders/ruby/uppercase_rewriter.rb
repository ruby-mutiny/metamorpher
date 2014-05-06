require "metamorpher/builders/ast"

module Metamorpher
  module Builders
    module Ruby
      class UppercaseRewriter
        include Metamorpher::Rewriter
        include Metamorpher::Builders::AST

        def pattern
          builder.VARIABLE_TO_BE { |v| v.name && v.name.to_s[/^[A-Z_]*$/] }
        end

        def replacement
          builder.derivation!(:variable_to_be) do |variable_to_be, builder|
            name = variable_to_be.name.to_s

            if name.end_with?("_")
              builder.greedy_variable! name.chomp("_").downcase.to_sym
            else
              builder.variable! name.downcase.to_sym
            end
          end
        end
      end
    end
  end
end
