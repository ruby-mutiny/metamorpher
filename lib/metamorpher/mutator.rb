require "metamorpher/transformer/base"
require "metamorpher/transformer/merger"

module Metamorpher
  module Mutator
    include Transformer::Base
    alias_method :mutate, :transform
    alias_method :mutate_file, :transform_file
    alias_method :mutate_files, :transform_files

    def merge(src, replacements, &block)
      replacements.map { |replacement| Transformer::Merger.new(src).merge(replacement, &block) }
    end
  end
end
