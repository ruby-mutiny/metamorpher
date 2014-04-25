require "metamorpher/drivers/ruby"
require "metamorpher/builder"

module Metamorpher
  module Drivers
    describe Ruby do
      let(:builder) { Metamorpher::Builder.new }

      describe "for a simple program" do
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

          expect(subject.source_location_for(literal)).to eq(0..4)
          expect(subject.source_location_for(literal.children.first)).to eq(0..0)
          expect(subject.source_location_for(literal.children.last)).to eq(4..4)
        end
      end

      %w(nil true false self).each do |keyword|
        describe "for a program containing the '#{keyword}' keyword" do
          let(:source)  { "a = #{keyword}" }
          let(:literal) { builder.lvasgn(:a, keyword.to_sym) }

          it "should parse to the correct literal" do
            expect(subject.parse(source)).to eq(literal)
          end

          it "should unparse to the correct source" do
            expect(subject.unparse(literal)).to eq(source)
          end
        end

        describe "for a program that is the '#{keyword}' keyword" do
          let(:source)  { keyword }
          let(:literal) { builder.literal! keyword.to_sym }

          it "should parse to the correct literal" do
            expect(subject.parse(source)).to eq(literal)
          end

          it "should unparse to the correct source" do
            expect(subject.unparse(literal)).to eq(source)
          end
        end
      end
    end
  end
end
