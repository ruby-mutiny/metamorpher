require "attributable"

module Metamorpher
  module Refactorer
    Site = Struct.new(:original_position, :original_code, :refactored_code) do
      def slide(offset)
        new_position = (original_position.begin + offset)..(original_position.end + offset)
        Site.new(new_position, original_code, refactored_code)
      end

      def merge_into(destination)
        if original_position.begin > destination.size
          fail ArgumentError, "Position #{original_position} does not exist in: #{destination}"
        end

        destination[original_position] = refactored_code
        destination
      end

      def offset
        refactored_code.size - original_code.size
      end

      def <=>(other)
        original_position.begin <=> other.original_position.begin
      end
    end
  end
end
