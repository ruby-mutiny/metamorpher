require "metamorpher/builders/ruby/builder"

module Metamorpher
  module Builders
    module Ruby
      def builder
        @builder ||= Builder.new
      end
    end
  end
end
