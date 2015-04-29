require "metamorpher/visitable/visitor"

module Metamorpher
  module Visitable
    describe Visitor do
      it "should call visitor based on the type of the visitee" do
        allow(subject).to receive(:visit_string)
        subject.visit("foo")
        expect(subject).to have_received(:visit_string)
      end

      it "should call visitor on ancestor of visitee if necessary" do
        allow(subject).to receive(:visit_numeric)
        subject.visit(3) # Fixnum < Integer < Numeric
        expect(subject).to have_received(:visit_numeric)
      end

      it "should call visitor based on unqualified type of the visitee" do
        allow(subject).to receive(:visit_dummy)
        subject.visit(Dummy.new)
        expect(subject).to have_received(:visit_dummy)
      end

      it "should raise if no appropriate visit method is defined" do
        expect { subject.visit("foo") }.to raise_error(ArgumentError)
      end
    end

    class Dummy; end
  end
end
