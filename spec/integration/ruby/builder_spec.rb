require "metamorpher"

Metamorpher.configure(builder: :ruby)

describe Metamorpher.builder do
  let(:ast_builder) { Metamorpher::Builders::AST::Builder.new }

  describe "when building literals" do
    it "should produce literals from source" do
      expect(subject.build("1 + 1")).to eq(
        ast_builder.literal!(
          :send,
          ast_builder.int(1),
          :+,
          ast_builder.int(1)
        )
      )
    end

    xit "should raise for invalid source" do
    end
  end

  describe "when building programs containing constants" do
    it "should convert uppercase constants to variables" do
      expect(subject.build("LEFT + RIGHT")).to eq(
        ast_builder.literal!(
          :send,
          ast_builder._left,
          :+,
          ast_builder._right
        )
      )
    end

    it "should not convert non-uppercase constants to variables" do
      expect(subject.build("Left + RIGHt")).to eq(
        ast_builder.literal!(
          :send,
          ast_builder.const(nil, :Left),
          :+,
          ast_builder.const(nil, :RIGHt)
        )
      )
    end
  end
end

Metamorpher.configure(builder: :ast)
