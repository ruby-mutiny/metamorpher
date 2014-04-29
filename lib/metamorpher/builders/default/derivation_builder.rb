require "metamorpher/terms/derived"
require "metamorpher/builders/default/builder"

module Metamorpher
  module Builders
    module Default
      class DerivationBuilder
        def derivation!(*base, &block)
          fail ArgumentError, "wrong number of arguments (0)" if base.empty?
          fail ArgumentError, "a block must be provided" if block.nil?

          Terms::Derived.new(
            base: base,
            derivation: ->(*args) { block.call(*args, Builder.new) }
          )
        end
      end
    end
  end
end
