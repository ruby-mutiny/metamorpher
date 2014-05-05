require "metamorpher"
require "metamorpher/refactorer"

class RefactorWhereFirstStubs
  include Metamorpher::Refactorer

  def pattern
    # "TYPE.stubs(:where).returns(EXPECTED_VALUE)" as an AST:
    builder.literal!(
      :send,
      builder.literal!(:send, builder.TYPE, :stubs, builder.sym(:where)),
      :returns,
      # Don't match non-array return types, such as Topic.stubs(:where).returns(Topic)
      builder.EXPECTED_VALUE { |l| l.name == :array }
    )
  end

  # rubocop:disable MethodLength
  def replacement
    # "TYPE.stubs(:find_by).returns(EXPECTED_VALUE)" as an AST
    builder.literal!(
      :send,
      builder.literal!(:send, builder.TYPE, :stubs, builder.sym(:find_by)),
      :returns,
      # Refactor the argument to "returns" from [] to nil or from [X] to X
      builder.derivation!(:expected_value) do |expected_value, builder|
        if expected_value.children.empty?
          builder.literal! :nil
        else
          expected_value.children.first
        end
      end
    )
  end
  # rubocop:enable MethodLength
end
