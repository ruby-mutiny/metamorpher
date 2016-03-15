require "metamorpher/drivers/parse_error"
require "metamorpher/terms/literal"
require "parser/current"
require "unparser"

module Metamorpher
  module Drivers
    class Ruby
      def parse(src)
        import(@root = parser.parse(src))
      rescue Parser::SyntaxError
        raise ParseError
      end

      def unparse(literal)
        unparser.unparse(export(literal))
      end

      def source_location_for(literal)
        ast = ast_for(literal)
        (ast.loc.expression.begin_pos..(ast.loc.expression.end_pos - 1))
      end

      private

      def import(ast)
        create_literal_for(ast)
      end

      def create_literal_for(ast)
        if ast.respond_to? :type
          Terms::Literal.new(name: ast.type, children: ast.children.map { |c| import(c) })
        else
          Terms::Literal.new(name: ast)
        end
      end

      def export(literal)
        if literal.branch?
          Parser::AST::Node.new(literal.name, literal.children.map { |c| export(c) })

        elsif keyword?(literal)
          # Unparser requires leaf nodes containing keywords to be represented as nodes.
          Parser::AST::Node.new(literal.name)

        else
          # Unparser requires all other leaf nodes to be represented as primitives.
          literal.name
        end
      end

      def keyword?(literal)
        literal.leaf? && !literal.child_of?(:sym) && keywords.include?(literal.name)
      end

      def keywords
        # The symbols used by Parser for Ruby keywords. The current implementation
        # is not a definitive list. If unparsing fails, it might be due to this list
        # omitting a necessary keyword. Note that these are the symbols produced
        # by Parser which are not necessarily the same as Ruby keywords (e.g.,
        # Parser sometimes produces a :zsuper node for a program of the form "super")
        @keywords ||= %i(nil false true self array hash)
      end

      def ast_for(literal)
        literal.path.reduce(@root) { |a, e| a.children[e] }
      end

      def parser
        @parser ||= Parser::CurrentRuby
      end

      def unparser
        @unparser ||= Unparser
      end
    end
  end
end
