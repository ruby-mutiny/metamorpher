require "metamorpher"

module Metamorpher
  describe Metamorpher do
    it "should provide a Ruby builder by default" do
      expect(subject.builder).to be_kind_of(Builders::Ruby::Builder)
    end

    describe "configure" do
      it "should be possible to change to an AST builder" do
        subject.configure(builder: :ast)
        expect(subject.builder).to be_kind_of(Builders::AST::Builder)
      end

      it "should be possible to change back to the Ruby builder" do
        subject.configure(builder: :ast)
        subject.configure(builder: :ruby)
        expect(subject.builder).to be_kind_of(Builders::Ruby::Builder)
      end
    end
  end
end
