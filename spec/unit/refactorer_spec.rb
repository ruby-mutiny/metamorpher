require "metamorpher"
require "metamorpher/refactorer"

module Metamorpher
  class SimpleRefactorer
    include Refactorer

    def pattern
      builder.if(builder._condition, :true, :false)
    end

    def replacement
      builder._condition
    end
  end

  describe SimpleRefactorer do
    let(:first_site)  { "if (a) then true else false end" }
    let(:second_site) { "if (b) then true else false end" }
    let(:third_site)  { "if (c) then true else false end" }

    describe "for a program that is a single refactoring site" do
      let(:source) { first_site }

      it "should refactor the expression" do
        expect(subject.refactor(source)).to eq("a")
      end

      it "should yield the replacement" do
        replacement = nil
        subject.refactor(source) { |r| replacement = r }

        check_replacement(replacement, first_site, "a")
      end
    end

    describe "for a program containing a single refactoring site" do
      let(:source) { "a = true\nb = #{first_site}\nputs b" }

      it "should refactor the expression" do
        expect(subject.refactor(source)).to eq("a = true\nb = a\nputs b")
      end

      it "should yield the replacement" do
        replacement = nil
        subject.refactor(source) { |r| replacement = r }

        check_replacement(replacement, first_site, "a")
      end
    end

    describe "for a program with several refactoring sites" do
      let(:source) do
        <<-eos
          a, b, c = true, false, true
          #{first_site}
          #{second_site}
          sleep 1
          #{third_site}
          puts a && b && c
        eos
      end

      it "should refactor the expression" do
        expect(subject.refactor(source)).to eq(
          <<-eos
          a, b, c = true, false, true
          a
          b
          sleep 1
          c
          puts a && b && c
          eos
        )
      end

      it "should yield all of the replacements" do
        replacements = []
        subject.refactor(source) { |r| replacements << r }

        check_replacement(replacements[0], first_site,  "a")
        check_replacement(replacements[1], second_site, "b")
        check_replacement(replacements[2], third_site,  "c")
      end
    end

    describe "for a program with no refactoring sites" do
      let(:source) { "2 + 2" }

      it "should not change the expression" do
        expect(subject.refactor(source)).to eq(source)
      end

      it "should not yield" do
        expect { |b| subject.refactor(source, &b) }.not_to yield_control
      end
    end

    def check_replacement(replacement, site, value)
      start = source.index(site)
      finish = start + site.length - 1

      expect(replacement.position).to eq(start..finish)
      expect(replacement.value).to eq(value)
    end
  end
end
