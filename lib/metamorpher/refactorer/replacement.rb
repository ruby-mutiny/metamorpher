require "attributable"

module Metamorpher
  module Refactorer
    Replacement = Struct.new(:position, :value) do
      def move_by!(offset)
        self.position = (position.begin + offset)..(position.end + offset)
      end

      def merge_into(destination)
        if position.begin > destination.size
          fail ArgumentError, "Position #{position} does not exist in: #{destination}"
        end

        destination[position] = value
        destination
      end

      def offset
        value.size - position.size
      end
    end
  end
end
