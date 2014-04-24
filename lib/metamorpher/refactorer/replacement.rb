require "attributable"

module Metamorpher
  module Refactorer
    Replacement = Struct.new(:position, :value) do
      def slide(offset)
        new_position = (position.begin + offset)..(position.end + offset)
        Replacement.new(new_position, value)
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
