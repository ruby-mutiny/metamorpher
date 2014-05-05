require "metamorpher"

describe Metamorpher.builder do
  it_behaves_like "a literal builder"
  it_behaves_like "a variable builder"
  it_behaves_like "a greedy variable builder"
  it_behaves_like "a derivation builder"
end
