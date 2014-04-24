require "metamorpher"
require "metamorpher/matcher"
require "metamorpher/matcher/match"

module Metamorpher
  class SimpleMatcher
    include Matcher

    def pattern
      builder.literal! 1
    end
  end

  describe SimpleMatcher do
    let(:builder) { Metamorpher.builder }

    it "should performing matching" do
      expression = builder.literal! 1
      expected = Matcher::Match.new(root: expression)

      expect(subject.run(expression)).to eq(expected)
    end
  end
end
