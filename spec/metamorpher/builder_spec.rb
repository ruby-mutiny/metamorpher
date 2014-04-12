require "metamorpher/builder"

module Metamorpher
  describe Builder do
    it_behaves_like "a literal builder"
    it_behaves_like "a variable builder"
    it_behaves_like "a greedy variable builder"
    it_behaves_like "a derivation builder"

    it "should raise when incorrect shorthand is used" do
      expect { subject.INC }.to raise_error(NoMethodError)
    end
  end
end
