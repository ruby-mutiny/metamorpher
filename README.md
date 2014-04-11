# Metamorpher [![Build Status](https://travis-ci.org/mutiny/metamorpher.png)](https://travis-ci.org/mutiny/metamorpher) [![Code Climate](https://codeclimate.com/github/mutiny/metamorpher.png)](https://codeclimate.com/github/mutiny/metamorpher) [![Dependency Status](https://gemnasium.com/mutiny/metamorpher.png)](https://gemnasium.com/mutiny/metamorpher) [![Coverage Status](https://coveralls.io/repos/mutiny/metamorpher/badge.png?branch=master)](https://coveralls.io/r/mutiny/metamorpher?branch=master)

A library for transforming Ruby programs.

## Basic usage

Here's a very simple example that rewrites expressions of the form `2 + 2` to expressions of the form `4`:

```ruby
require "metamorpher/literal"

expression = Metamorpher::Literal.new(
  name: :+,
  children: [
    Metamorpher::Literal.new(name: 2),
    Metamorpher::Literal.new(name: 2)
  ]
) # => +(2,2)

TwoPlusTwoRewriter.new.rewrite(expression) # => 4
```
    
The implementation of TwoPlusTwoRewriter is as follows:

```ruby
require "metamorpher/rule"

class TwoPlusTwoRewriter
  def rewrite(expression)
    rule.apply(expression)
  end
  
  private
  
  def rule
    Metamorpher::Rule.new(pattern: pattern, replacement: replacement)
  end
  
  def pattern
    Metamorpher::Literal.new(
      name: :+,
      children: [
        Metamorpher::Literal.new(name: 2),
        Metamorpher::Literal.new(name: 2)
      ]
    )
  end
  
  def replacement
    Metamorpher::Literal.new(name: 4)
  end
end
```

Note that a rule has no effect if it is applied to an expression that does not match its pattern:

```ruby
expression = Metamorpher::Literal.new(
  name: :+,
  children: [
    Metamorpher::Literal.new(name: 3),
    Metamorpher::Literal.new(name: 2)
  ]
) # => +(3,2)

TwoPlusTwoRewriter.new.rewrite(expression) # => +(3,2)
```

### Variables

Rewriting becomes a lot more useful when we are able to capture some parts of the expression during matching, and then re-use the captured parts in the replacement. Metamorpher provides variables for this purpose. For example:

```ruby
expression = Metamorpher::Literal.new(
  name: :inc,
  children: [Metamorpher::Literal.new(name: 2)]
) # => inc(2)

IncrementRewriter.new.rewrite(expression) # => +(2,1)


expression = Metamorpher::Literal.new(
  name: :inc,
  children: [Metamorpher::Literal.new(name: 3)]
) # => inc(3)

IncrementRewriter.new.rewrite(expression) # => +(3,1)


expression = Metamorpher::Literal.new(
  name: :inc,
  children: [Metamorpher::Literal.new(name: :n)]
) # => inc(n)

IncrementRewriter.new.rewrite(expression) # => +(:n,1)


expression = Metamorpher::Literal.new(
  name: :inc,
  children: [
    Metamorpher::Literal.new(
      name: :inc,
      children: [Metamorpher::Literal.new(name: 2)]
    )
  ]
) # => inc(inc(2))

IncrementRewriter.new.rewrite(expression) # => +(inc(2),1)
```

The implementation of `IncrementRewriter` makes uses of a variable to capture the argument passed to `inc`:

```ruby
require "metamorpher/literal"
require "metamorpher/variable"
require "metamorpher/rule"

class IncrementRewriter
  def rewrite(expression)
    rule.apply(expression)
  end
  
  private
  
  def rule
    Metamorpher::Rule.new(pattern: pattern, replacement: replacement)
  end
  
  def pattern
    Metamorpher::Literal.new(
      name: :inc,
      children: [
        Metamorpher::Variable.new(name: :incrementee),
      ]
    )
  end
  
  def replacement
    Metamorpher::Literal.new(
      name: :+,
      children: [
        Metamorpher::Variable.new(name: :incrementee),
        Metamorpher::Literal.new(name: 1),
      ]
    )
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
