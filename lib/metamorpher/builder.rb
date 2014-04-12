require "metamorpher/builders/literal_builder"
require "metamorpher/builders/variable_builder"
require "metamorpher/builders/greedy_variable_builder"
require "metamorpher/builders/derivation_builder"

module Metamorpher
  class Builder
    extend Forwardable
    def_delegator :literal_builder, :literal!
    def_delegator :variable_builder, :variable!
    def_delegator :greedy_variable_builder, :greedy_variable!
    def_delegator :derivation_builder, :derivation!

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
      @literal_builder ||= Builders::LiteralBuilder.new
    end

    def variable_builder
      @variable_builder ||= Builders::VariableBuilder.new
    end

    def greedy_variable_builder
      @greedy_variable_builder ||= Builders::GreedyVariableBuilder.new
    end

    def derivation_builder
      @derivation_builder ||= Builders::DerivationBuilder.new
    end
  end
end
