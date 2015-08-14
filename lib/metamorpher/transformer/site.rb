require "attributable"

module Metamorpher
  module Transformer
    Site = Struct.new(:original_position, :original_code, :transformed_code) do
      def slide(offset)
        new_position = (original_position.begin + offset)..(original_position.end + offset)
        Site.new(new_position, original_code, transformed_code)
      end

      def merge_into(destination)
        if original_position.begin > destination.size
          fail ArgumentError, "Position #{original_position} does not exist in: #{destination}"
        end

        destination[original_position] = transformed_code
        destination
      end

      def offset
        transformed_code.size - original_code.size
      end

      def <=>(other)
        original_position.begin <=> other.original_position.begin
      end
    end
  end
end
