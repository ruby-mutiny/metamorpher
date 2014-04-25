require "metamorpher/refactorer/merger"
require "metamorpher/refactorer/replacement"
require "metamorpher/builder"
require "metamorpher/rewriter/rule"
require "metamorpher/drivers/ruby"

module Metamorpher
  module Refactorer
    def refactor(src, &block)
      literal = driver.parse(src)
      replacements = reduce_to_replacements(literal)
      Merger.new(src).merge(*replacements, &block)
    end

    def refactor_file(path, &block)
      changes = []
      refactored = refactor(File.read(path)) { |change| changes << change }
      block.call(path, refactored, changes) if block
      refactored
    end

    def refactor_files(paths, &block)
      paths.reduce({}) do |result, path|
        result[path] = refactor_file(path, &block)
        result
      end
    end

    def builder
      @builder ||= Builder.new
    end

    def driver
      @driver ||= Metamorpher::Drivers::Ruby.new
    end

    private

    def reduce_to_replacements(literal)
      [].tap do |replacements|
        rule.reduce(literal) do |original, rewritten|
          position = driver.source_location_for(original)
          new_code = driver.unparse(rewritten)
          replacements << Replacement.new(position, new_code)
        end
      end
    end

    def rule
      @rule ||= Rewriter::Rule.new(pattern: pattern, replacement: replacement)
    end
  end
end
