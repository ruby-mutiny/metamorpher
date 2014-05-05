require "metamorpher/builders/ruby/ensuring_visitor"
require "metamorpher/builders/ruby/deriving_visitor"

module Metamorpher
  module Builders
    module Ruby
      module Term
        def ensuring(variable_name, &condition)
          accept_and_decorate(
            EnsuringVisitor.new(
              variable_name.downcase.to_sym,
              condition
            )
          )
        end

        def deriving(variable_name, *base_names, &derivation)
          accept_and_decorate(
            DerivingVisitor.new(
              variable_name.downcase.to_sym,
              *base_names.map { |n| n.downcase.to_sym },
              derivation
            )
          )
        end

        private

        def accept_and_decorate(visitor)
          accept(visitor).extend(Term)
        end
      end
    end
  end
end
