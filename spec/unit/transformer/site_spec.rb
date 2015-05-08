require "metamorpher/transformer/site"

module Metamorpher
  module Transformer
    describe Site do
      subject { Site.new(4..6, "foo", "bar") }

      describe "slide" do
        it "should return a replacement with the new position" do
          expect(subject.slide(2).original_position).to eq(6..8)
        end

        it "should not alter the code" do
          expect(subject.slide(2).original_code).to eq("foo")
          expect(subject.slide(2).refactored_code).to eq("bar")
        end

        it "should be chainable" do
          expect(subject.slide(2).slide(10).original_position).to eq(16..18)
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
          expect(Site.new(4..6, "foo", "b").offset).to eq(-2)
        end

        it "should be +ve when position's size is smaller than value's size" do
          expect(Site.new(4..6, "foo", "baaz").offset).to eq(1)
        end
      end
    end
  end
end
