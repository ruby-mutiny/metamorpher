require "attributable"

module Metamorpher
  module Refactorer
    Replacement = Struct.new(:position, :value) do
      def move_by!(offset)
        self.position = (position.first + offset)..(position.last + offset - 1)
      end

      def merge_into(destination)
        destination[position] = value
      end

      def offset
        value.size - position.size
      end
    end
  end
end
