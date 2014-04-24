require "metamorpher/refactorer/merger"
require "metamorpher/refactorer/replacement"
require "metamorpher/builder"
require "metamorpher/rewriting/rule"
require "metamorpher/drivers/ruby"

module Metamorpher
  module Refactorer
    def refactor(src, &block)
      replacements = reduce_to_replacements(driver.parse(src))
      Merger.new(src).merge(*replacements, &block)
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
      @rule ||= Rewriting::Rule.new(pattern: pattern, replacement: replacement)
    end
  end
end