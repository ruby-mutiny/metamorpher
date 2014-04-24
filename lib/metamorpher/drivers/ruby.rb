require "metamorpher/rewriter/literal"
require "parser/current"
require "unparser"

module Metamorpher
  module Drivers
    class Ruby
      def parse(src)
        import(parser.parse(src))
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
        create_literal_for(ast).tap do |literal|
          asts[literal] = ast
        end
      end

      def create_literal_for(ast)
        if ast.respond_to? :type
          Rewriter::Literal.new(name: ast.type, children: ast.children.map { |c| import(c) })
        else
          Rewriter::Literal.new(name: ast)
        end
      end

      def export(literal)
        if literal.children.empty?
          literal.name
        else
          Parser::AST::Node.new(literal.name, literal.children.map { |c| export(c) })
        end
      end

      def ast_for(literal)
        asts[literal]
      end

      def parser
        @parser ||= Parser::CurrentRuby
      end

      def unparser
        @unparser ||= Unparser
      end

      def asts
        @asts ||= {}
      end
    end
  end
end
