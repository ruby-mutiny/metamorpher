require "metamorpher"
require "metamorpher/refactorer"

class RefactorWhereFirstMocks
  include Metamorpher::Refactorer

  def pattern
    # "TYPE.expects(:where).returns(EXPECTED_VALUE)" as an AST:
    builder.literal!(
      :send,
      builder.literal!(:send, builder.TYPE, :expects, builder.sym(:where)),
      :returns,
      builder.EXPECTED_VALUE
    )
  end

  # rubocop:disable MethodLength
  def replacement
    # "TYPE.expects(:find_by).returns(EXPECTED_VALUE)" as an AST:
    builder.literal!(
      :send,
      builder.literal!(:send, builder.TYPE, :expects, builder.sym(:find_by)),
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
