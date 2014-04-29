require "metamorpher"
require "metamorpher/refactorer"

class RefactorWhereFirstNotCalledExpectations
  include Metamorpher::Refactorer

  def pattern
    # "TYPE.expects(:where).never" as an AST:
    builder.literal!(
      :send,
      builder.literal!(:send, builder._type, :expects, builder.sym(:where)),
      :never
    )
  end

  def replacement
    # "TYPE.expects(:find_by).never" as an AST:
    builder.literal!(
      :send,
      builder.literal!(:send, builder._type, :expects, builder.sym(:find_by)),
      :never
    )
  end
end
