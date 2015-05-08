require "attributable"

module Metamorpher
  module Transformer
    Merger = Struct.new(:original) do
      def merge(*replacements, &block)
        original.dup.tap do |merged|
          replacements.sort.reduce(0) do |offset, replacement|
            yield replacement if block
            replacement = replacement.slide(offset)
            replacement.merge_into(merged)
            offset + replacement.offset
          end
        end
      end
    end
  end
end
