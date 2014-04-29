require "metamorpher/builders/default/builder"

module Metamorpher
  module Builders
    module Default
      def builder
        @builder ||= Builder.new
      end
    end
  end
end
