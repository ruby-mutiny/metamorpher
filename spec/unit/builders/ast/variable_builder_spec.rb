require "metamorpher/builders/ast/variable_builder"

describe Metamorpher::Builders::AST::VariableBuilder do
  it_behaves_like "a variable builder"

  it "should raise when incorrect shorthand is used" do
    expect { subject.inc }.to raise_error(NoMethodError)
  end
end
