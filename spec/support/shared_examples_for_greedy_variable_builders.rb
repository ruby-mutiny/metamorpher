require "metamorpher/rewriting/variable"

module Metamorpher
  module Rewriting
    shared_examples "a greedy variable builder" do
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
          expect { subject.greedy_variable!(:a, 1) }.to raise_error(ArgumentError)
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
          expect { subject._a(:greedy, 1) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
