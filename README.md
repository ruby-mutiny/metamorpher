# Metamorph [![Build Status](https://travis-ci.org/mutiny/metamorph.png)](https://travis-ci.org/mutiny/metamorph) [![Code Climate](https://codeclimate.com/github/mutiny/metamorph.png)](https://codeclimate.com/github/mutiny/metamorph) [![Dependency Status](https://gemnasium.com/mutiny/metamorph.png)](https://gemnasium.com/mutiny/metamorph) [![Coverage Status](https://coveralls.io/repos/mutiny/metamorph/badge.png?branch=master)](https://coveralls.io/r/mutiny/metamorph?branch=master)

A library for transforming Ruby programs.

## Installation

Metamorph is best used with the wonderful [parser](https://github.com/whitequark/parser) and [unparser](https://github.com/mbj/unparser) gems.

Add these line to your application's Gemfile:

    gem 'parser'
    gem 'unparser'
    gem 'metamorph'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metamorph

## Basic usage

Below is a very simple (and currently verbose) example that refactors Ruby on Rails programs from the form `MyType.where(params).first` to the form `MyType.find_by(params)`.

    require "metamorph"
    require "parser/current"
    require "unparser"
    
    class WhereFirstRewriter
      
      def apply(path)
        ast = parse(File.read(path))
        
        # TODO repeat until no matches
        ast = rule.apply(ast)
        
        File.open(path, 'w') {|f| f.write(unparse(ast)) }
      end
      
      private
      
      ## TODO make import part of the library, and then uncomment the following version of parse
      ## def parse(source)
      ##   Metamorph::Parser.import(Parser::CurrentRuby.parse(source))
      ## end
      
      def parse(source)
        import(Parser::CurrentRuby.parse(source))
      end

      def unparse(ast)
        Unparser.unparse(ast)
      end

      def import(ast)
        if ast.respond_to? :type
          Node.new(type: ast.type, children: ast.children.map { |c| import(c) })
        else
          Node.new(type: ast)
        end
      end
      
      def rule
        # The following is a verbose way of specifying the
        # following:
        #   pattern = TYPE.where(PARAMS).first
        #   replacement = TYPE.find_by(PARAMS)
        #   rule = pattern -> replacement
        #
        # A better interface will be added in a future version of metamorph!
    
        pattern = Node.new(
          type: :send, 
          children: [
            Node.new(
              type: :send,
              children: [
                Variable.new(name: :type),
                Node.new(type: :where),
                Variable.new(name: :params)
              ]
            ),
            Node.new(
              type: :first
            )
          ]
        )
    
        replacement = Node.new(
          type: :send, 
          children: [
            Variable.new(name: :type),
            Node.new(type: :find_by),
            Variable.new(name: :params)
          ]
        )
    
        Rule.new(pattern: pattern, replacement: replacement)
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
