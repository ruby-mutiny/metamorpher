require "metamorpher"
require "metamorpher/refactorer"

class RefactorWhereFirstToFindBy
  include Metamorpher::Refactorer

  def pattern
    # "TYPE.where(PARAMS...).first" as an AST:
    builder.literal!(
      :send,
      builder.literal!(:send, builder._type, :where, builder._params(:greedy)),
      :first
    )
  end

  def replacement
    # "TYPE.find_by(PARAMS...)" as an AST:
    builder.literal!(:send, builder._type, :find_by, builder._params)
  end
end
