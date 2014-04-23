require "metamorpher/rewriting/literal"
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
          Rewriting::Literal.new(name: ast.type, children: ast.children.map { |c| import(c) })
        else
          Rewriting::Literal.new(name: ast)
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

# # Extract into reusable "Ruby driver" or "Ruby adapter"
# require "metamorpher/rewriting/literal"
#
# def import(ast)
#   imported = if ast.respond_to? :type
#     Metamorpher::Rewriting::Literal.new(...)
#   else
#     Metamorpher::Rewriting::Literal.new(name: ast)
#   end
#
#   @trace ||= {}
#   @trace[imported] = ast
#
#   imported
# end
#
# def export(literal)
#   if literal.children.empty?
#     literal.name
#   else
#     Parser::AST::Node.new(literal.name, literal.children.map { |c| export(c) })
#   end
# end
#
# require "parser/current"
#
# path = File.expand_path("../discourse_posts_controller.rb", __FILE__)
# src = File.read(path)
# parsed = Parser::CurrentRuby.parse(src)
# imported = import(parsed)
#
# impacted = []
#
# require "unparser"
#
# WhereFirstRefactorer.new.reduce(imported) do |original, rewritten|
#   impacted << [@trace[original].loc.expression, Unparser.unparse(export(rewritten))]
# end
#
# correction = 0
# impacted.each do |change|
#   start, finish = change.first.begin_pos+correction, change.first.end_pos-1+correction
#   original, replacement = src[start..finish], change.last
#   src[start..finish] = replacement
#   puts "Between #{start} and #{finish}, inserted:\n\t#{replacement}"
#   correction = replacement.length - original.length
#   puts correction
#   puts ""
#   puts ""
# end
