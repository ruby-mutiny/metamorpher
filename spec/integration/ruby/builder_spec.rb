require "metamorpher"

Metamorpher.configure(builder: :ruby)

describe Metamorpher.builder do
  let(:default_builder) { Metamorpher::Builders::Default::Builder.new }

  describe "when building literals" do
    it "should produce literals from source" do
      expect(subject.build("1 + 1")).to eq(
        default_builder.literal!(
          :send,
          default_builder.int(1),
          :+,
          default_builder.int(1)
        )
      )
    end

    xit "should raise for invalid source" do
    end
  end

  describe "when building programs containing constants" do
    it "should convert uppercase constants to variables" do
      expect(subject.build("LEFT + RIGHT")).to eq(
        default_builder.literal!(
          :send,
          default_builder._left,
          :+,
          default_builder._right
        )
      )
    end

    it "should not convert non-uppercase constants to variables" do
      expect(subject.build("Left + RIGHt")).to eq(
        default_builder.literal!(
          :send,
          default_builder.const(nil, :Left),
          :+,
          default_builder.const(nil, :RIGHt)
        )
      )
    end
  end
end

Metamorpher.configure(builder: :default)
