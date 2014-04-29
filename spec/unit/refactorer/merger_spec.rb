require "metamorpher/refactorer/merger"
require "metamorpher/refactorer/replacement"

module Metamorpher
  module Refactorer
    describe Merger do
      let(:original) { "The quick brown fox jumps over the lazy dog." }
      subject { Merger.new(original) }

      describe "for a single replacement" do
        it "should be able to rewrite at the start of the string" do
          merged = merge(Replacement.new(0..2, "A"))

          expect(merged).to eq("A quick brown fox jumps over the lazy dog.")
        end

        it "should be able to rewrite in the middle of the string" do
          merged = merge(Replacement.new(4..8, "swift"))

          expect(merged).to eq("The swift brown fox jumps over the lazy dog.")
        end

        it "should be able to rewrite at the end of the string" do
          merged = merge(Replacement.new(43..43, "!"))

          expect(merged).to eq("The quick brown fox jumps over the lazy dog!")
        end

        it "should not alter the original string" do
          merge(Replacement.new(0..2, "A"))

          expect(original).to eq("The quick brown fox jumps over the lazy dog.")
        end

        it "should yield before performing the replacement" do
          replacement = Replacement.new(0..2, "A")

          expect { |b| merge(replacement, &b) }.to yield_with_args(replacement)
        end
      end

      describe "for multiple replacements" do
        it "should merge all replacements" do
          merged = merge(
            Replacement.new(4..8, "swift"),
            Replacement.new(20..24, "walks"),
            Replacement.new(40..42, "cat")
          )

          expect(merged).to eq("The swift brown fox walks over the lazy cat.")
        end

        it "should determine position of all replacements based on the original string" do
          merged = merge(
            Replacement.new(4..8, "fast"),
            Replacement.new(20..24, "springs"),
            Replacement.new(40..42, "cat")
          )

          # note that "fast" is 1 char shorter than its replacee "quick"
          # and hence the second substring has to be repositioned by -1 char
          # and that "springs" is 2 chars longer than its replacee "jumps"
          # and hence the third substring has to be repositioned by +1 char (as -1 + +2 = +1)

          expect(merged).to eq("The fast brown fox springs over the lazy cat.")
        end

        it "should yield before performing each replacement" do
          replacements = [
            Replacement.new(4..8, "swift"),
            Replacement.new(20..24, "walks"),
            Replacement.new(40..42, "cat")
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
