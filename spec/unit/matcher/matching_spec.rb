require "metamorpher/terms/variable"
require "metamorpher/terms/literal"
require "metamorpher/terms/derived"

module Metamorpher
  module Terms
    describe Variable do
      let(:root) do
        Literal.new(
          name: :root,
          children: [
            Literal.new(name: :first_child),
            Literal.new(name: :second_child),
            Literal.new(name: :third_child)
          ]
        )
      end

      let(:first_child)  { root.children[0] }
      let(:second_child) { root.children[1] }
      let(:third_child)  { root.children[2] }

      describe "unconditional, non-greedy variable" do
        subject { Variable.new(name: :type) }

        it "should match any literal" do
          expect(subject.match(root)).to have_matched(root)
        end

        it "should include the match in the substitution" do
          expect(subject.match(root)).to have_substitution(type: root)
        end

        it "shouldn't match nil" do
          expect(subject.match(nil)).not_to have_matched
        end
      end

      describe "conditional, non-greedy variable" do
        subject { Variable.new(name: :type, condition: -> (l) { l.name == :third_child }) }

        it "should match when literal matches condition" do
          expect(subject.match(third_child)).to have_matched(third_child)
        end

        it "shouldn't match when literal doesn't match condition" do
          expect(subject.match(second_child)).not_to have_matched
        end

        it "shouldn't match nil" do
          expect(subject.match(nil)).not_to have_matched
        end
      end

      describe "unconditional, greedy variable" do
        subject { Variable.new(name: :type, greedy?: true) }

        it "should match against literal and all younger siblings" do
          result = subject.match(second_child)

          expect(result).to have_matched([second_child, third_child])
          expect(result).to have_substitution(type: [second_child, third_child])
        end

        it "should match against literal when there is no parent" do
          result = subject.match(root)

          expect(result).to have_matched([root])
          expect(result).to have_substitution(type: [root])
        end

        it "should allow parent to match when there are a different number of children" do
          wrapped_subject = Literal.new(name: :root, children: [subject])
          result = wrapped_subject.match(root)

          expect(result).to have_matched(root)
          expect(result).to have_substitution(type: root.children)
        end

        it "shouldn't match nil" do
          expect(subject.match(nil)).not_to have_matched
        end
      end

      describe "conditional, greedy variable" do
        subject { Variable.new(name: :type, greedy?: true, condition: -> (ls) { ls.size == 2 }) }

        it "should match when literal matches condition" do
          result = subject.match(second_child)

          expect(result).to have_matched([second_child, third_child])
          expect(result).to have_substitution(type: [second_child, third_child])
        end

        it "should not match when literal doesn't match condition" do
          expect(subject.match(third_child)).not_to have_matched
        end

        it "shouldn't match nil" do
          expect(subject.match(nil)).not_to have_matched
        end
      end

      describe Literal do
        describe "with no children" do
          let(:literal) { Literal.new(name: :root) }

          it "should match when names match" do
            matchee = Literal.new(name: :root)

            expect(literal.match(matchee)).to have_matched(matchee)
          end

          it "shouldn't match when names don't match" do
            matchee = Literal.new(name: :not_found)

            expect(literal.match(matchee)).not_to have_matched
          end

          it "should be able to match nils" do
            literal = Literal.new(name: nil)
            matchee = Literal.new(name: nil)

            expect(literal.match(matchee)).to have_matched(matchee)
          end
        end

        describe "with children" do
          let(:root) do
            Literal.new(
              name: :root,
              children: [
                Literal.new(name: :first_child),
                Literal.new(name: :second_child),
                Literal.new(name: :third_child)
              ]
            )
          end

          let(:first_child)  { root.children[0] }
          let(:second_child) { root.children[1] }
          let(:third_child)  { root.children[2] }

          it "should match when children match" do
            matchee = Literal.new(
              name: :root,
              children: [
                Literal.new(name: :first_child),
                Literal.new(name: :second_child),
                Literal.new(name: :third_child)
              ]
            )

            expect(root.match(matchee)).to have_matched(matchee)
          end

          it "should not match when children don't match" do
            matchee = Literal.new(
              name: :root,
              children: [
                Literal.new(name: :primer_hijo),
                Literal.new(name: :segundo_hijo),
                Literal.new(name: :tercero_hijo)
              ]
            )

            expect(root.match(matchee)).not_to have_matched
          end

          it "should not match when there are too few children" do
            matchee = Literal.new(
              name: :root,
              children: [
                Literal.new(name: :first_child),
                Literal.new(name: :second_child)
              ]
            )

            expect(root.match(matchee)).not_to have_matched
          end

          it "should not match when there are too many children" do
            matchee = Literal.new(
              name: :root,
              children: [
                Literal.new(name: :first_child),
                Literal.new(name: :second_child),
                Literal.new(name: :third_child),
                Literal.new(name: :fourth_child)
              ]
            )

            expect(root.match(matchee)).not_to have_matched
          end

          it "builds substitution from children" do
            root = Literal.new(
              name: :root,
              children: [
                Variable.new(name: :first),
                Literal.new(name: :second_child),
                Variable.new(name: :last)
              ]
            )

            matchee = Literal.new(
              name: :root,
              children: [
                Literal.new(name: :first_child),
                Literal.new(name: :second_child),
                Literal.new(name: :third_child)
              ]
            )

            expect(root.match(matchee)).to have_substitution(first: first_child, last: third_child)
          end
        end
      end

      describe Derived do
        it "should raise" do
          root = Derived.new
          matchee = Literal.new(name: :root)

          expect { root.match(matchee) }.to raise_error(Matcher::MatchingError)
        end
      end
    end
  end
end
