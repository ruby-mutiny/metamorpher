require "metamorpher"

describe Metamorpher do
  subject { Metamorpher.builder }

  before { Metamorpher.configure(builder: :ast)  }
  after  { Metamorpher.configure(builder: :ruby) }

  it_behaves_like "a literal builder"
  it_behaves_like "a variable builder"
  it_behaves_like "a greedy variable builder"
  it_behaves_like "a derivation builder"
end
