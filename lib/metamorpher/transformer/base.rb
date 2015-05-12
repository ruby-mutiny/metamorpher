require "metamorpher/transformer/merger"
require "metamorpher/transformer/site"
require "metamorpher/rewriter/rule"
require "metamorpher/drivers/ruby"

module Metamorpher
  module Transformer
    module Base
      def transform(src, &block)
        literal = driver.parse(src)
        replacements = reduce_to_replacements(src, literal)
        merge(src, replacements, &block)
      end

      def transform_file(path, &block)
        transform(File.read(path), &block)
      end

      def transform_files(paths, &block)
        paths.each_with_object({}) do |path, result|
          changes = []
          result[path] = transform_file(path) { |change| changes << change }
          block.call(path, result[path], changes) if block
        end
      end

      def driver
        @driver ||= Metamorpher::Drivers::Ruby.new
      end

      private

      def reduce_to_replacements(src, literal)
        [].tap do |replacements|
          rule.reduce(literal) do |original, rewritings|
            original_position = driver.source_location_for(original)
            original_code = src[original_position]

            rewritings.alternatives.each do |rewriting|
              replacements << Site.new(original_position, original_code, driver.unparse(rewriting))
            end
          end
        end
      end

      def rule
        @rule ||= Rewriter::Rule.new(pattern: pattern, replacement: replacement)
      end
    end
  end
end
