require "metamorpher/support/map_at"

describe Enumerable do
  subject { %w(foo bar baz) }

  describe "map_at" do
    it "should return a new array with the specified replacement" do
      expect(subject.map_at(0) { |w| w.reverse }).to eq(%w(oof bar baz))
      expect(subject.map_at(1) { |w| w.reverse }).to eq(%w(foo rab baz))
      expect(subject.map_at(2) { |w| w.reverse }).to eq(%w(foo bar zab))
    end

    it "should raise when index is out of range" do
      expect { subject.map_at(-1) }.to raise_error(IndexError)
      expect { subject.map_at(3) }.to raise_error(IndexError)
    end
  end
end
