require "metamorpher"

module Metamorpher
  describe Metamorpher do
    it "should provide a default builder" do
      expect(subject.builder).to be_kind_of(Builders::Default::Builder)
    end

    describe "configure" do
      it "should change the builder" do
        subject.configure(builder: :ruby)
        expect(subject.builder).to be_kind_of(Builders::Ruby::Builder)
      end
    end
  end
end
