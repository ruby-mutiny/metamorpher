require "metamorpher/drivers/ruby"
require "metamorpher/builder"

module Metamorpher
  module Drivers
    describe Ruby do
      let(:builder) { Metamorpher::Builder.new }
      let(:source)  { "1 + 2" }
      let(:literal) { builder.literal!(:send, builder.int(1), :+, builder.int(2)) }

      it "should parse a simple program to literals" do
        expect(subject.parse(source)).to eq(literal)
      end

      it "should unparse valid literals to source" do
        expect(subject.unparse(literal)).to eq(source)
      end

      it "should be able to provide source location of literals" do
        subject.parse(source)

        expect(subject.source_location_for(literal)).to eq(0..5)
        expect(subject.source_location_for(literal.children.first)).to eq(0..1)
        expect(subject.source_location_for(literal.children.last)).to eq(4..5)
      end
    end
  end
end
