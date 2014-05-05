module Metamorpher
  module Builders
    module Ruby
      class UppercaseConstantRewriter
        include Metamorpher::Rewriter

        def pattern
          builder.const(
            builder.literal!(nil),
            builder.VARIABLE_TO_BE { |v| !v.name[/\p{Lower}/] }
          )
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
