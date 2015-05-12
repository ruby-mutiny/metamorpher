require "metamorpher/terms/term_set"
require "metamorpher/builders/ast/literal_builder"
require "metamorpher/builders/ast/variable_builder"
require "metamorpher/builders/ast/greedy_variable_builder"
require "metamorpher/builders/ast/derivation_builder"
require "metamorpher/builders/ast/term_set_builder"
require "forwardable"

module Metamorpher
  module Builders
    module AST
      class Builder
        extend Forwardable
        def_delegator :literal_builder, :literal!
        def_delegator :variable_builder, :variable!
        def_delegator :greedy_variable_builder, :greedy_variable!
        def_delegator :derivation_builder, :derivation!
        def_delegator :term_set_builder, :either!

        def method_missing(method, *arguments, &block)
          builders_with_shorthand
            .find { |builder| builder.shorthand?(method, *arguments, &block) }
            .method_missing(method, *arguments, &block)
        end

        private

        def builders_with_shorthand
          @builders ||= [
            literal_builder,
            variable_builder,
            greedy_variable_builder
          ]
        end

        def literal_builder
          @literal_builder ||= LiteralBuilder.new
        end

        def variable_builder
          @variable_builder ||= VariableBuilder.new
        end

        def greedy_variable_builder
          @greedy_variable_builder ||= GreedyVariableBuilder.new
        end

        def derivation_builder
          @derivation_builder ||= DerivationBuilder.new
        end

        def term_set_builder
          @term_set_builder ||= TermSetBuilder.new
        end
      end
    end
  end
end
