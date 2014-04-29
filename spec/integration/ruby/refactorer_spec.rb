require "metamorpher"

describe "Refactorer" do
  let(:builder) { Metamorpher.builder }

  describe "for Ruby" do
    class UnnecessaryConditionalRefactorer
      include Metamorpher::Refactorer

      def pattern
        builder.if(builder._condition, :true, :false)
      end

      def replacement
        builder._condition
      end
    end

    subject { UnnecessaryConditionalRefactorer.new }

    let(:refactorable) do
      "def run\n" \
      "  a = #{refactorable_code_for("some_predicate")}\n" \
      "  b = #{refactorable_code_for("some_other_predicate")}\n" \
      "end"
    end

    let(:refactored) do
      "def run\n" \
      "  a = some_predicate\n" \
      "  b = some_other_predicate\n" \
      "end"
    end

    let(:not_refactorable) { "nothing_to_see_here = 42" }

    describe "by calling refactor" do
      describe "for code that can be refactored" do
        it "should return the refactored code" do
          expect(subject.refactor(refactorable)).to eq(refactored)
        end

        it "should yield for each refactoring site" do
          expect { |b| subject.refactor(refactorable, &b) }.to yield_successive_args(
            site_for(14..55, "some_predicate"),
            site_for(63.. 110, "some_other_predicate")
          )
        end
      end

      describe "for code that cannot be refactored" do
        it "should return the original code" do
          expect(subject.refactor(not_refactorable)).to eq(not_refactorable)
        end

        it "should not yield when there are no refactoring site" do
          expect { |b| subject.refactor(not_refactorable, &b) }.not_to yield_control
        end
      end
    end

    describe "refactor_file" do
      describe "for code that can be refactored" do
        let(:refactorable_file) { create_temporary_ruby_file("refactorable", refactorable) }

        it "should return the refactored code" do
          expect(subject.refactor_file(refactorable_file)).to eq(refactored)
        end

        it "should yield for each refactoring site" do
          expect { |b| subject.refactor_file(refactorable_file, &b) }.to yield_successive_args(
            site_for(14..55, "some_predicate"),
            site_for(63.. 110, "some_other_predicate")
          )
        end
      end

      describe "for code that cannot be refactored" do
        let(:not_refactorable_file) do
          create_temporary_ruby_file("not_refactorable", not_refactorable)
        end

        it "should return the original code" do
          expect(subject.refactor_file(not_refactorable_file)).to eq(not_refactorable)
        end

        it "should not yield when there are no refactoring site" do
          expect { |b| subject.refactor_file(not_refactorable_file, &b) }.not_to yield_control
        end
      end
    end

    describe "refactor_files" do
      let(:refactorable_file) { create_temporary_ruby_file("refactorable", refactorable) }
      let(:clone_of_refactorable_file) { create_temporary_ruby_file("refactorable", refactorable) }

      let(:different_refactoring_sites_file) do
        create_temporary_ruby_file(
          "differently_refactorable",
          "c = if yet_another_predicate then true else false end"
        )
      end

      let(:not_refactorable_file) do
        create_temporary_ruby_file(
          "not_refactorable",
          "nothing_to_see_here = 42"
        )
      end

      let(:files) do
        [
          refactorable_file,
          clone_of_refactorable_file,
          different_refactoring_sites_file,
          not_refactorable_file
        ]
      end

      it "should return a map of the paths and refactored code" do
        refactored_files = {
          refactorable_file => refactored,
          clone_of_refactorable_file => refactored,
          different_refactoring_sites_file => "c = yet_another_predicate",
          not_refactorable_file => "nothing_to_see_here = 42"
        }

        expect(subject.refactor_files(files)).to eq(refactored_files)
      end

      it "should yield for each file" do
        refactorable_file_details = [
          refactorable_file,
          refactored,
          [
            site_for(14..55, "some_predicate"),
            site_for(63.. 110, "some_other_predicate")
          ]
        ]

        clone_of_refactorable_file_details = [
          clone_of_refactorable_file,
          refactored,
          [
            site_for(14..55, "some_predicate"),
            site_for(63.. 110, "some_other_predicate")
          ]
        ]

        different_refactoring_sites_file_details = [
          different_refactoring_sites_file,
          "c = yet_another_predicate",
          [
            site_for(4..52, "yet_another_predicate")
          ]
        ]

        not_refactorable_file_details = [
          not_refactorable_file,
          "nothing_to_see_here = 42",
          []
        ]

        summary = []
        subject.refactor_files(files) { |*args| summary << args }

        expect(summary[0]).to eq(refactorable_file_details)
        expect(summary[1]).to eq(clone_of_refactorable_file_details)
        expect(summary[2]).to eq(different_refactoring_sites_file_details)
        expect(summary[3]).to eq(not_refactorable_file_details)
      end
    end

    def refactorable_code_for(predicate)
      "if #{predicate} then true else false end"
    end

    def site_for(original_position, predicate)
      Metamorpher::Refactorer::Site.new(
        original_position,
        refactorable_code_for(predicate),
        predicate
      )
    end

    def create_temporary_ruby_file(filename, contents)
      Tempfile.new([filename, ".rb"]).tap do |tempfile|
        tempfile.write(contents)
        tempfile.close
      end.path
    end
  end
end
