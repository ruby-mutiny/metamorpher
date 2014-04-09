require "attributable"

module Metamorph
  class Rule
    extend Attributable
    attributes :pattern, :replacement

    def apply(ast)
      result = match(ast)

      if ast == result.root
        replacement.substitute(result.substitution)
      else
        ast.replace(result.root, replacement.substitute(result.substitution))
      end
    end

    private

    def match(ast)
      waiting, discovered, result = [ast], [], nil
      loop do
        current = waiting.pop
        unless discovered.include?(current)
          discovered << current
          waiting.concat(current.children)
        end
        result = pattern.match(current)
        return result if result.matches?
      end
    end
  end
end
