require "attributable"

module Metamorpher
  module Refactorer
    Merger = Struct.new(:original) do
      def merge(*replacements, &block)
        original.dup.tap do |merged|
          replacements.reduce(0) do |offset, replacement|
            yield replacement.dup if block
            replacement.move_by!(offset)
            replacement.merge_into(merged)
            offset + replacement.offset
          end
        end
      end
    end
  end
end
