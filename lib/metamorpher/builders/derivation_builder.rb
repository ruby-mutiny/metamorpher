require "metamorpher/terms/derived"
require "metamorpher/builder"

module Metamorpher
  module Builders
    class DerivationBuilder
      def derivation!(*base, &block)
        fail ArgumentError, "wrong number of arguments (0)" if base.empty?
        fail ArgumentError, "a block must be provided" if block.nil?

        Terms::Derived.new(
          base: base,
          derivation: ->(*args) { block.call(*args, Metamorpher::Builder.new) }
        )
      end
    end
  end
end
