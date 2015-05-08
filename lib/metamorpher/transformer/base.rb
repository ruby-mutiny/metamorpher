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
          rules.each do |rule| # FIXME : change to inject?
            rule.reduce(literal) do |original, rewritten|
              original_position = driver.source_location_for(original)
              original_code = src[original_position]
              transformed_code = driver.unparse(rewritten)
              replacements << Site.new(original_position, original_code, transformed_code)
            end
          end
        end
      end

      def rules
        @rules ||= replacements.map { |r| Rewriter::Rule.new(pattern: pattern, replacement: r) }
      end
    end
  end
end
