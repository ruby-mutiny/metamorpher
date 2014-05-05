require "metamorpher"
require "metamorpher/refactorer"

class RefactorWhereFirstToFindBy
  include Metamorpher::Refactorer

  def pattern
    # "TYPE.where(PARAMS...).first" as an AST:
    builder.literal!(
      :send,
      builder.literal!(:send, builder.TYPE, :where, builder.PARAMS_),
      :first
    )
  end

  def replacement
    # "TYPE.find_by(PARAMS...)" as an AST:
    builder.literal!(:send, builder.TYPE, :find_by, builder.PARAMS_)
  end
end
