require "metamorpher/builders/variable_builder"

module Metamorpher
  module Builders
    describe VariableBuilder do
      it_behaves_like "a variable builder"

      it "should raise when incorrect shorthand is used" do
        expect { subject.inc }.to raise_error(NoMethodError)
      end
    end
  end
end
