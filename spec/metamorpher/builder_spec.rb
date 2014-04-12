require "metamorpher/builder"

module Metamorpher
  describe Builder do
    describe "literal!" do
      it "should create an instance of Literal" do
        actual = subject.literal!(:a)
        expected = Literal.new(name: :a)

        expect(actual).to eq(expected)
      end

      it "should work with numeric names" do
        actual = subject.literal!(4)
        expected = Literal.new(name: 4)

        expect(actual).to eq(expected)
      end

      it "should capture single children" do
        actual = subject.literal!(:inc, subject.literal!(1))
        expected = Literal.new(name: :inc, children: [Literal.new(name: 1)])

        expect(actual).to eq(expected)
      end

      it "should capture several children" do
        actual = subject.literal!(:add, subject.literal!(1), subject.literal!(2))
        expected = Literal.new(
          name: :add,
          children: [
            Literal.new(name: 1),
            Literal.new(name: 2)
          ]
        )

        expect(actual).to eq(expected)
      end

      it "should automatically convert children to literals" do
        actual = subject.literal!(:add, 1, 2)
        expected = Literal.new(
          name: :add,
          children: [
            Literal.new(name: 1),
            Literal.new(name: 2)
          ]
        )

        expect(actual).to eq(expected)
      end

      it "should not automatically convert children that are already terms" do
        actual = subject.literal!(:inc, subject.variable!(:a))
        expected = Literal.new(name: :inc, children: [Variable.new(name: :a)])

        expect(actual).to eq(expected)
      end
    end

    describe "literal shorthand" do
      it "should create an instance of Literal" do
        actual = subject.a
        expected = Literal.new(name: :a)

        expect(actual).to eq(expected)
      end

      it "should capture children" do
        actual = subject.add(1, 2)
        expected = Literal.new(
          name: :add,
          children: [
            Literal.new(name: 1),
            Literal.new(name: 2)
          ]
        )

        expect(actual).to eq(expected)
      end
    end

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
        expect { subject.variable!(:inc, 1) }.to raise_error
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
        expect { subject._inc(1) }.to raise_error
      end
    end

    describe "greedy_variable!" do
      it "should create an instance of Variable with greedy? set to true" do
        actual = subject.greedy_variable!(:a)
        expected = Variable.new(name: :a, greedy?: true)

        expect(actual).to eq(expected)
      end

      it "should create condition from block" do
        built = subject.greedy_variable!(:a) { |term| term > 0 }

        expect(built.name).to eq(:a)
        expect(built.condition.call(1)).to be_true
        expect(built.condition.call(-1)).to be_false
      end

      it "should not allow children" do
        expect { subject.greedy_variable!(:inc, 1) }.to raise_error
      end
    end

    describe "greedy variable shorthand" do
      it "should create an instance of Variable with greedy? set to true" do
        actual = subject._a :greedy
        expected = Variable.new(name: :a, greedy?: true)

        expect(actual).to eq(expected)
      end

      it "should create condition from block" do
        built = subject._a(:greedy) { |term| term > 0 }

        expect(built.name).to eq(:a)
        expect(built.condition.call(1)).to be_true
        expect(built.condition.call(-1)).to be_false
      end

      it "should not allow children" do
        expect { subject._inc(:greedy, 1) }.to raise_error
      end
    end
  end
end
