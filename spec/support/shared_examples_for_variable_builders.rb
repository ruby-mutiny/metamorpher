require "metamorpher/variable"

module Metamorpher
  shared_examples "a variable builder" do
    describe "variable!" do
      it "should create an instance of Variable" do
        actual = subject.variable!(:a)
        expected = Variable.new(name: :a)

        expect(actual).to eq(expected)
      end

      it "should create condition from block" do
        built = subject.variable!(:a) { |term| term > 0 }

        expect(built.name).to eq(:a)
        expect(built.condition.call(1)).to be_true
        expect(built.condition.call(-1)).to be_false
      end

      it "should not allow children" do
        expect { subject.variable!(:a, 1) }.to raise_error(ArgumentError)
      end
    end

    describe "variable shorthand" do
      it "should create an instance of Variable" do
        actual = subject._a
        expected = Variable.new(name: :a)

        expect(actual).to eq(expected)
      end

      it "should create condition from block" do
        built = subject._a { |term| term > 0 }

        expect(built.name).to eq(:a)
        expect(built.condition.call(1)).to be_true
        expect(built.condition.call(-1)).to be_false
      end

      it "should not allow children" do
        expect { subject._a(1) }.to raise_error(ArgumentError)
      end
    end
  end
end
