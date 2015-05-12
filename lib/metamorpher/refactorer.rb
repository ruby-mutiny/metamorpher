require "metamorpher/transformer/base"
require "metamorpher/transformer/merger"

module Metamorpher
  module Refactorer
    include Transformer::Base
    alias_method :refactor, :transform
    alias_method :refactor_file, :transform_file
    alias_method :refactor_files, :transform_files

    def merge(src, replacements, &block)
      Transformer::Merger.new(src).merge(*replacements, &block)
    end
  end
end
