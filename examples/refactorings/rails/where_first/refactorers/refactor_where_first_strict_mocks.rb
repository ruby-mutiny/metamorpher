require "metamorpher"
require "metamorpher/refactorer"

class RefactorWhereFirstStrictMocks
  include Metamorpher::Refactorer

  # rubocop:disable MethodLength
  def pattern
    # "TYPE.expects(:where).with(PARAMS...).returns(EXPECTED_VALUE)" as an AST:
    builder.literal!(
      :send,
      builder.literal!(
        :send,
        builder.literal!(:send, builder._type, :expects, builder.sym(:where)),
        :with,
        builder._params(:greedy)
      ),
      :returns,
      builder._expected_value
    )
  end
  # rubocop:enable MethodLength

  # rubocop:disable MethodLength
  def replacement
    # "TYPE.expects(:find_by).with(PARAMS...).returns(EXPECTED_VALUE)" as an AST:
    builder.literal!(
      :send,
      builder.literal!(
        :send,
        builder.literal!(:send, builder._type, :expects, builder.sym(:find_by)),
        :with,
        builder._params
      ),
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
