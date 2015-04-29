require "metamorpher/drivers/ruby"
require "metamorpher/builders/ast/builder"

module Metamorpher
  module Drivers
    describe Ruby do
      let(:builder) { Builders::AST::Builder.new }

      describe "for a simple program" do
        let(:source)  { "1 + 2" }
        let(:literal) { builder.literal!(:send, builder.int(1), :+, builder.int(2)) }

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end

        it "should provide source location of literals" do
          subject.parse(source)

          expect(subject.source_location_for(literal)).to eq(0..4)
          expect(subject.source_location_for(literal.children.first)).to eq(0..0)
          expect(subject.source_location_for(literal.children.last)).to eq(4..4)
        end
      end

      describe "for program containing identical statements" do
        let(:source)  { "1 + 1" }
        let(:literal) { builder.literal!(:send, builder.int(1), :+, builder.int(1)) }

        it "should provide different source locations for syntactically equal literals" do
          subject.parse(source)

          expect(subject.source_location_for(literal.children.first)).to eq(0..0)
          expect(subject.source_location_for(literal.children.last)).to eq(4..4)
        end
      end

      describe "for program that parses to an AST containing nils" do
        let(:source)  { "LEFT + RIGHT" }
        let(:literal) do
          builder.literal!(
            :send,
            builder.const(nil, :LEFT),
            :+,
            builder.const(nil, :RIGHT)
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
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
