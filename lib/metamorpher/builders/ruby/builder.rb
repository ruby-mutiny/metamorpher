require "metamorpher/drivers/ruby"
require "metamorpher/builders/ruby/term"
require "metamorpher/builders/ruby/uppercase_constant_rewriter"
require "metamorpher/builders/ruby/uppercase_rewriter"

module Metamorpher
  module Builders
    module Ruby
      class Builder
        def build(source)
          decorate(rewrite(parse(source)))
        end

        private

        def decorate(term)
          term.extend(Term)
        end

        def rewrite(parsed)
          rewriters.reduce(parsed) { |a, e| e.reduce(a) }
        end

        def parse(source)
          driver.parse(source)
        end

        def rewriters
          @rewriters ||= [UppercaseConstantRewriter.new, UppercaseRewriter.new]
        end

        def driver
          @driver ||= Drivers::Ruby.new
        end
      end
    end
  end
end
