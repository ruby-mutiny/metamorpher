require "metamorpher/builders/ast/literal_builder"

describe Metamorpher::Builders::AST::LiteralBuilder do
  it_behaves_like "a literal builder"

  it "should raise when variable shorthand is used" do
    expect { subject._inc }.to raise_error(NoMethodError)
  end
end
