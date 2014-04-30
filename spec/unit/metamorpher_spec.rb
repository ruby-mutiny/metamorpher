require "metamorpher"

module Metamorpher
  describe Metamorpher do
    it "should provide an AST builder by default" do
      expect(subject.builder).to be_kind_of(Builders::AST::Builder)
    end

    describe "configure" do
      it "should be possible to change to a Ruby builder" do
        subject.configure(builder: :ruby)
        expect(subject.builder).to be_kind_of(Builders::Ruby::Builder)
      end

      it "should be possible to change back to the AST builder" do
        subject.configure(builder: :ruby)
        subject.configure(builder: :ast)
        expect(subject.builder).to be_kind_of(Builders::AST::Builder)
      end
    end
  end
end
