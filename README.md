# Metamorpher [![Build Status](https://travis-ci.org/mutiny/metamorpher.png)](https://travis-ci.org/mutiny/metamorpher) [![Code Climate](https://codeclimate.com/github/mutiny/metamorpher.png)](https://codeclimate.com/github/mutiny/metamorpher) [![Dependency Status](https://gemnasium.com/mutiny/metamorpher.png)](https://gemnasium.com/mutiny/metamorpher) [![Coverage Status](https://coveralls.io/repos/mutiny/metamorpher/badge.png?branch=master)](https://coveralls.io/r/mutiny/metamorpher?branch=master)

A term rewriting library for transforming (Ruby) programs.

## Basic usage

Here's a very simple example that rewrites expressions of the form `succ(0)` to expressions of the form `1`:

```ruby
require "metamorpher"

expression = Metamorpher.builder.succ(0) # => succ(0)
  
TwoPlusTwoRewriter.new.run(expression) # => 1
```
    
The implementation of TwoPlusTwoRewriter is as follows:

```ruby
class TwoPlusTwoRewriter
  include Metamorpher::Rewriter
  
  def pattern
    builder.succ(0)
  end
  
  def replacement
    builder.literal!(1)
  end
end
```

Note that a rule has no effect if it is applied to an expression that does not match its pattern:

```ruby
expression = Metamorpher.builder.succ(1) # => succ(1)

TwoPlusTwoRewriter.new.run(expression) # => succ(1)
```

### Variables

Rewriting becomes a lot more useful when we are able to capture some parts of the expression during matching, and then re-use the captured parts in the replacement. Metamorpher provides variables for this purpose. For example:

```ruby
expression = Metamorpher.builder.inc(2) # => inc(2)

IncrementRewriter.new.rewrite(expression) # => +(2,1)


expression = Metamorpher.builder.inc(3) # => inc(3)

IncrementRewriter.new.rewrite(expression) # => +(3,1)


expression = Metamorpher.builder.inc(:n) # => inc(n)

IncrementRewriter.new.rewrite(expression) # => +(n,1)


expression = Metamorpher.builder.inc(Metamorpher.builder.inc(:n)) # => inc(inc(n))

IncrementRewriter.new.rewrite(expression) # => +(inc(n),1)
```

The implementation of `IncrementRewriter` makes uses of a variable to capture the argument passed to `inc`:

```ruby
class IncrementRewriter
  include Metamorpher::Rewriter
  
  def pattern
    builder.inc(builder._incrementee)
  end
  
  def replacement
    builder.+(builder._incrementee, 1)
  end
end
```
    
#### Conditional variables

#### Greedy variables

### Derivations
    
### Rewriting Ruby programs
To use metamorpher to rewrite Ruby programs, I recommend the wonderful [parser](https://github.com/whitequark/parser) and [unparser](https://github.com/mbj/unparser) gems.

__TODO__ example of rewriting a Ruby program

## Installation

Add these line to your application's Gemfile:

    gem 'metamorpher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metamorpher

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgments

Thank-you to the authors of other projects and resources that have inspired metamorpher, including:

* Paul Klint's [tutorial on term rewriting](http://www.meta-environment.org/doc/books/extraction-transformation/term-rewriting/term-rewriting.html), which metamorpher is heavily based on.
* Jim Weirich's [Builder](https://github.com/jimweirich/builder) gem, which heavily influenced the design of Metamorpher::Builder.