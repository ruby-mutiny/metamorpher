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

  describe "when building literals containing uppercase constants" do
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
  end
end

Metamorpher.configure(builder: :default)
