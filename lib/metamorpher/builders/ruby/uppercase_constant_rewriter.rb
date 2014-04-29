module Metamorpher
  module Builders
    module Ruby
      class UppercaseConstantRewriter
        include Metamorpher::Rewriter

        def pattern
          builder.const(
            builder.literal!(nil),
            builder._variable_to_be { |v| !v.name[/\p{Lower}/] }
          )
        end

        def replacement
          builder.derivation!(:variable_to_be) do |variable_to_be, builder|
            builder.variable! variable_to_be.name.downcase
          end
        end
      end
    end
  end
end
