require "metamorpher/terms/derived"
require "metamorpher/builders/ast/builder"

module Metamorpher
  module Builders
    module AST
      class DerivationBuilder
        def derivation!(*base, &block)
          fail ArgumentError, "wrong number of arguments (0)" if base.empty?

          Terms::Derived.new(
            base: base,
            derivation: derivation_strategy(block)
          )
        end

        private

        def derivation_strategy(block)
          if block.nil?
            ->(*args) { args.first }
          else
            ->(*args) { block.call(*args, Builder.new) }
          end
        end
      end
    end
  end
end
