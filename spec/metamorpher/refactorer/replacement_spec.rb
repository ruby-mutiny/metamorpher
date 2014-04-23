require "metamorpher/refactorer/replacement"

module Metamorpher
  module Refactorer
    describe Replacement do
      subject { Replacement.new(4..6, "bar") }

      describe "move_by!" do
        it "should change the position of the existing replacement" do
          subject.move_by! 2

          expect(subject.position).to eq(6..8)
        end

        it "should work for multiple calls" do
          subject.move_by! 2
          subject.move_by! 10

          expect(subject.position).to eq(16..18)
        end
      end

      describe "merge_into" do
        it "should apply change to argument" do
          expect(subject.merge_into("foo foo")).to eq("foo bar")
        end

        it "should raise error when mergee is shorter than start of position" do
          expect { subject.merge_into("foo") }.to raise_error(ArgumentError)
        end

        it "should not raise error when mergee is same length as start of position" do
          expect { subject.merge_into("foo ") }.to_not raise_error
        end
      end

      describe "offset" do
        it "should be 0 when position and value are the same size" do
          expect(subject.offset).to eq(0)
        end

        it "should be -ve when position's size is larger than value's size" do
          expect(Replacement.new(4..6, "a").offset).to eq(-2)
        end

        it "should be +ve when position's size is smaller than value's size" do
          expect(Replacement.new(4..6, "baaz").offset).to eq(1)
        end
      end
    end
  end
end
