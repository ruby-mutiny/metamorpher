require "metamorpher/builders/literal_builder"

module Metamorpher
  module Builders
    describe LiteralBuilder do
      it_behaves_like "a literal builder"

      it "should raise when variable shorthand is used" do
        expect { subject._inc }.to raise_error(NoMethodError)
      end
    end
  end
end
