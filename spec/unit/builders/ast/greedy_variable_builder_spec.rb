require "metamorpher/builders/ast/greedy_variable_builder"

describe Metamorpher::Builders::AST::GreedyVariableBuilder do
  it_behaves_like "a greedy variable builder"

  it "should raise when incorrect shorthand is used" do
    expect { subject.inc }.to raise_error(NoMethodError)
  end
end
