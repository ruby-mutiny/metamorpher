require "metamorpher/drivers/ruby"
require "metamorpher/builders/ruby/term"
require "metamorpher/builders/ruby/uppercase_constant_rewriter"

module Metamorpher
  module Builders
    module Ruby
      class Builder
        def build(source)
          rewriter.reduce(driver.parse(source)).extend(Term)
        end

        private

        def rewriter
          @rewriter ||= UppercaseConstantRewriter.new
        end

        def driver
          @driver ||= Drivers::Ruby.new
        end
      end
    end
  end
end
