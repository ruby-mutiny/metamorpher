require "metamorpher/transformer/merger"
require "metamorpher/transformer/site"

module Metamorpher
  module Transformer
    describe Merger do
      let(:original) { "The quick brown fox jumps over the lazy dog." }
      subject { Merger.new(original) }

      describe "for a single replacement" do
        it "should be able to rewrite at the start of the string" do
          merged = merge(Site.new(0..2, "The", "A"))

          expect(merged).to eq("A quick brown fox jumps over the lazy dog.")
        end

        it "should be able to rewrite in the middle of the string" do
          merged = merge(Site.new(4..8, "quick", "swift"))

          expect(merged).to eq("The swift brown fox jumps over the lazy dog.")
        end

        it "should be able to rewrite at the end of the string" do
          merged = merge(Site.new(43..43, ".", "!"))

          expect(merged).to eq("The quick brown fox jumps over the lazy dog!")
        end

        it "should not alter the original string" do
          merge(Site.new(0..2, "The", "A"))

          expect(original).to eq("The quick brown fox jumps over the lazy dog.")
        end

        it "should yield before performing the replacement" do
          replacement = Site.new(0..2, "The", "A")

          expect { |b| merge(replacement, &b) }.to yield_with_args(replacement)
        end
      end

      describe "for multiple replacements" do
        it "should merge all replacements" do
          merged = merge(
            Site.new(4..8, "quick", "swift"),
            Site.new(20..24, "jumps", "walks"),
            Site.new(40..42, "dog", "cat")
          )

          expect(merged).to eq("The swift brown fox walks over the lazy cat.")
        end

        it "should determine position of all replacements based on the original string" do
          merged = merge(
            Site.new(4..8, "quick", "fast"),
            Site.new(20..24, "jumps", "springs"),
            Site.new(40..42, "dog", "cat")
          )

          # note that "fast" is 1 char shorter than its replacee "quick"
          # and hence the second substring has to be repositioned by -1 char
          # and that "springs" is 2 chars longer than its replacee "jumps"
          # and hence the third substring has to be repositioned by +1 char (as -1 + +2 = +1)

          expect(merged).to eq("The fast brown fox springs over the lazy cat.")
        end

        it "should yield before performing each replacement" do
          replacements = [
            Site.new(4..8, "quick", "fast"),
            Site.new(20..24, "jumps", "springs"),
            Site.new(40..42, "dog", "cat")
          ]

          expect { |b| merge(*replacements, &b) }.to yield_successive_args(*replacements)
        end
      end

      def merge(*replacements, &block)
        subject.merge(*replacements, &block)
      end
    end
  end
end
