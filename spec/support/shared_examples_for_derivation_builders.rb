require "metamorpher/rewriting/literal"

module Metamorpher
  module Rewriting
    shared_examples "a derivation builder" do
      describe "derivation!" do
        it "should create an instance of Derivation" do
          built = subject.derivation!(:method) do |method|
            Literal.new(name: (method.name.to_s + "s").to_sym)
          end

          expect(built.base).to eq([:method])
          expect(built.derivation.call(Literal.new(name: :dog))).to eq(Literal.new(name: :dogs))
        end

        it "should capture all arguments as the base" do
          built = subject.derivation!(:key, :value) {}

          expect(built.base).to eq([:key, :value])
        end

        it "should provide a builder for use in the block" do
          built = subject.derivation!(:key, :value) do |key, value, builder|
            builder.pair(key, value)
          end

          derived = built.derivation.call(
            Literal.new(name: :dog),
            Literal.new(name: :lassie)
          )

          paired = Literal.new(
            name: :pair,
            children: [
              Literal.new(name: :dog),
              Literal.new(name: :lassie)
            ]
          )

          expect(derived).to eq(paired)
        end

        it "should raise if no arguments are passed" do
          expect { subject.derivation! { nil } }.to raise_error(ArgumentError)
        end

        it "should raise if no block is passed" do
          expect { subject.derivation!(:method) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
