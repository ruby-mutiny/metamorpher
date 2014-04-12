require "metamorpher/builders/literal_builder"
require "metamorpher/builders/variable_builder"
require "metamorpher/builders/greedy_variable_builder"

module Metamorpher
  class Builder
    extend Forwardable
    def_delegator :literal_builder, :literal!
    def_delegator :variable_builder, :variable!
    def_delegator :greedy_variable_builder, :greedy_variable!

    def method_missing(method, *arguments, &block)
      builders
        .find { |builder| builder.shorthand?(method, *arguments, &block) }
        .method_missing(method, *arguments, &block)
    end

    private

    def builders
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
  end
end
