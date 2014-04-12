require "metamorpher"
require "metamorpher/rewriter"

module Metamorpher
  class SimpleRewriter
    include Rewriter

    def pattern
      builder.literal! 1
    end

    def replacement
      builder.literal! 2
    end
  end

  describe SimpleRewriter do
    let(:builder) { Metamorpher.builder }

    it "should performing rewriting" do
      original = builder.literal! 1
      expected = builder.literal! 2

      expect(subject.run(original)).to eq(expected)
    end
  end
end
