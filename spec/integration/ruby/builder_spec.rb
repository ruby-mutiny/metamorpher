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

    it "should convert uppercase constants ending with underscore to greedy variables" do
      expect(subject.build("LEFT_ + RIGHT_")).to eq(
        ast_builder.literal!(
          :send,
          ast_builder._left(:greedy),
          :+,
          ast_builder._right(:greedy)
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

  describe "when building programs with conditional variables" do
    it "should create a conditional variable from a call to ensuring" do
      built = subject.build("A").ensuring("A") { |n| n > 0 }

      expect(built.name).to eq(:a)
      expect(built.condition.call(1)).to be_true
      expect(built.condition.call(-1)).to be_false
    end

    it "should create several conditional variables from several calls to ensuring" do
      built = subject
        .build("A + B")
        .ensuring("A") { |n| n > 0 }
        .ensuring("B") { |n| n < 0 }

      first_variable, _operator, last_variable = built.children

      expect(first_variable.name).to eq(:a)
      expect(first_variable.condition.call(1)).to be_true
      expect(first_variable.condition.call(-1)).to be_false

      expect(last_variable.name).to eq(:b)
      expect(last_variable.condition.call(-1)).to be_true
      expect(last_variable.condition.call(1)).to be_false
    end
  end

  describe "when building programs with derivations" do
    it "should create a derivation from a call to deriving" do
      built = subject.build("PLURAL").deriving("PLURAL", "SINGULAR") do |constant|
        subject.build(constant.children.last.name.to_s + "s")
      end

      expect(built.base).to eq([:singular])
      expect(built.derivation.call(subject.build("dog"))).to eq(subject.build("dogs"))
    end

    it "should create a derivation with multiple bases from a call to deriving" do
      built = subject.build("HASH").deriving("HASH", "KEY", "VALUE") {}

      expect(built.base).to eq([:key, :value])
    end

    it "should create several derivations from several calls to deriving" do
      built = subject
        .build("NEW_FIRST; NEW_LAST")
        .deriving("NEW_FIRST", "FIRST") {}
        .deriving("NEW_LAST", "LAST") {}

      first_derived, last_derived = built.children

      expect(first_derived.base).to eq([:first])
      expect(last_derived.base).to eq([:last])
    end
  end
end

Metamorpher.configure(builder: :ast)
