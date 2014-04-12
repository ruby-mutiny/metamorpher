# Metamorpher [![Build Status](https://travis-ci.org/mutiny/metamorpher.png)](https://travis-ci.org/mutiny/metamorpher) [![Code Climate](https://codeclimate.com/github/mutiny/metamorpher.png)](https://codeclimate.com/github/mutiny/metamorpher) [![Dependency Status](https://gemnasium.com/mutiny/metamorpher.png)](https://gemnasium.com/mutiny/metamorpher) [![Coverage Status](https://coveralls.io/repos/mutiny/metamorpher/badge.png?branch=master)](https://coveralls.io/r/mutiny/metamorpher?branch=master)

A term rewriting library for transforming (Ruby) programs.

## Basic usage

Here's a very simple example that rewrites expressions of the form `succ(0)` to expressions of the form `1`:

```ruby
require "metamorpher"

class SuccZeroRewriter
  include Metamorpher::Rewriter
  
  def pattern
    builder.succ(0)
  end
  
  def replacement
    builder.literal!(1)
  end
end

expression = Metamorpher.builder.succ(0) # => succ(0)
SuccZeroRewriter.new.run(expression) # => 1
```

This example is simple, but demonstrates many of the key concepts in metamorpher. You might now want to read about:

* [Rewriters](#rewriters) - how transform expressions into other expressions.
* [Matchers](#matchers) - how to determine whether an expression adheres to a pattern (i.e., matches a term).
* [Building terms](#building-terms) - how to create the data structure (terms) used by Rewriters and Matchers.
* [Practical examples](#practical-examples) - examples of using metamorpher to refactor Ruby programs

### Rewriters

Rewriters perform small, in-place changes to an expression. They can be used for program transformations, such as refactorings. For some simple program transformations, a regular expression can be used on the program source. For more complicated transformations, a term rewriting system (such as the one provided by `Metamorpher::Rewriter`) is likely to be a better fit.

Metamorpher provides the `Metamorpher::Rewriter` module for specifying rewriters. Include it, specify a `pattern` and a `replacement`, and then call `run` on an expression:

```ruby
require "metamorpher"

class SuccZeroRewriter
  include Metamorpher::Rewriter
  
  def pattern
    builder.succ(0)
  end
  
  def replacement
    builder.literal!(1)
  end
end

expression = Metamorpher.builder.succ(0) # => succ(0)
SuccZeroRewriter.new.run(expression) # => 1
```

Note that `run` has no effect when called on an expression that does not match `pattern`:

```ruby
expression = Metamorpher.builder.succ(1) # => succ(1)
SuccZeroRewriter.new.run(expression) # => succ(1)
```

#### Derivations

Rewriting is even more powerful when we are able to adjust the expression that is substituted for a captured variable. Metamorpher provides derivations for this purpose. (You may wish to read the section on [variables](#variables) before looking at the following example).

For example, suppose that we wish to create a rewriter that pluralises any literal. The following rewriter achieves this, by using a derivation (see the implementation of `replacement`) to create a new literal after an expression has been matched. Crucially, the derivation uses data from the captured literal when building the replacement literal:

```ruby
class PluraliseRewriter
  include Metamorpher::Rewriter
  
  def pattern
    builder._singular
  end
  
  def replacement
    builder.derivation! :singular do |singular|
      builder.literal!(singular.name + "s")
    end
  end
end

PluraliseRewriter.new.run(Metamorpher.builder.literal! "dog") # => "dogs"
```

Derivations can be based on more than one captured variable. In which case the call to `derivation!` and the block take more than one argument:

```ruby
builder.derivation! :key, :value do |key, value|
  builder.literal!(:pair, key, value)
end
```

### Matchers

Matchers search for subexpressions that adhere to a specified pattern. They are used be rewriters to find transformation sites in expressions, and can also be used to search programs. For simple searches over a program's source code, a regular expression can be used. For more complicated searches, a term matching system (such as the one provided by `Metamorpher::Matcher`) is likely to be a better fit.

Metamorpher provides the `Metamorpher::Matcher` module for specifying matchers. Include it, specify a `pattern` and then call `run` on an expression:

```ruby
require "metamorpher"

class SuccZeroMatcher
  include Metamorpher::Matcher
  
  def pattern
    builder.succ(0)
  end
end

expression = Metamorpher.builder.succ(0) # => succ(0)
result = SuccZeroMatcher.new.run(expression)
 # => <Metamorpher::Matching::Match root=succ(0), substitution={}> 
result.matches? # => true

expression = Metamorpher.builder.succ(1) # => succ(1)
result = SuccZeroMatcher.new.run(expression)
 # => <Metamorpher::Matching::NoMatch>
result.matches? # => false
```

#### Variables

Matching is more powerful when we can allow for some variability in the expressions that we wish to match. Metamorpher provides variables for this purpose.

For example, suppose we wish to match expressions of the form `succ(X)` where X could be any subexpression. The following matcher achieves this, by using a variable (`x`) to match the argument to `succ`:

Rewriting becomes a lot more useful when we are able to capture some parts of the expression during matching, and then re-use the captured parts in the replacement. Metamorpher provides variables for this purpose. For example:

```ruby
class SuccMatcher
  include Metamorpher::Matcher
  
  def pattern
    builder.succ(builder._x)
  end
end

expression = Metamorpher.builder.succ(0) # => succ(0)
SuccMatcher.new.run(expression)
 # => <Metamorpher::Matching::Match root=succ(0), substitution={:x=>0}> 

expression = Metamorpher.builder.succ(1) # => succ(1)
SuccMatcher.new.run(expression)
 # => <Metamorpher::Matching::Match root=succ(0), substitution={:x=>1}>
 
expression = Metamorpher.builder.succ(:n) # => succ(n)
SuccMatcher.new.run(expression)
 # => <Metamorpher::Matching::Match root=succ(n), substitution={:x=>n}>

expression = Metamorpher.builder.succ(Metamorpher.builder.succ(:n)) # => succ(succ(n))
SuccMatcher.new.run(expression)
 # => <Metamorpher::Matching::Match root=succ(succ(n)), substitution={:x=>succ(n)}> 
```
    
#### Conditional variables

By default, a variable matches any literal. Matching is more powerful when variables are able to match only those literals that satisfy some condition. Metamorpher provides conditional variables for this purpose.

For example, suppose that we wish to create a matcher that only matches method calls of the form `User.find_by_XXX`, but not calls to `User.find`, `User.where` or `User.find_by`. The following matcher achieves this, by using a conditional variable (`method`). Note that the condition is specified via the block passed when building the variable:

```ruby
class DynamicFinderMatcher
  include Metamorpher::Matcher
  
  def pattern
    builder.literal!(
      :".",
      :User,
      builder._method { |literal| literal.name =~ /^find_by_/ }
    )
  end
end

expression = Metamorpher.builder.literal!(:".", :User, :find_by_name) # => .(User, find_by_name)
DynamicFinderMatcher.new.run(expression)
 # => #<Metamorpher::Matching::Match root=.(User, find_by_name), substitution={:method=>find_by_name}> 

expression = Metamorpher.builder.literal!(:".", :User, :find) # => .(User, find)
DynamicFinderMatcher.new.run(expression)
 # => #<Metamorpher::Matching::NoMatch>
```

#### Greedy variables

Sometimes a matchers needs to be able to match an expression that contains a variable number of subexpressions. Metamorpher provides greedy variables for this purpose.

For example, suppose that we wish to create a matcher that works for an expression, `add`, that can have 1 or more children. The following matcher achieves this, by using a greedy variable (`args`).

```ruby
class MultiAddMatcher
  include Metamorpher::Matcher
  
  def pattern
    builder.add(
      builder._args(:greedy)
    )
  end
end

MultiAddMatcher.new.run(Metamorpher.builder.add(1,2))
 # => #<Metamorpher::Matching::Match root=add(1,2), substitution={:args=>[1, 2]}> 

MultiAddMatcher.new.run(Metamorpher.builder.add(1,2,3))
 # => #<Metamorpher::Matching::Match root=add(1,2,3), substitution={:args=>[1, 2, 3]}> 
```

### Building terms

The primary data structure used for [rewriting](#rewriters) and for [matching](#matchers) is a term. A term is a tree (i.e., an acyclic graph). The nodes of the tree are either:

* Literal - a node of the abstract-syntax tree of a program.
* Variable - a named node, which is bound to a subterm (subtree) during matching
* Greedy variable - a variable that is bound to a set of subterms during matching
* Derivation - a placeholder node, which is replaced during rewriting

To simplify the construction of terms, metamorpher provides the `Metamorpher::Builder` class:

```ruby
require "metamorpher"

builder = Metamorpher::Builder.new

builder.literal! :succ # => succ
builder.literal! 4 # => 4

builder.variable! :n # => N
builder.greedy_variable! :n # => N+

builder.derivation! :singular do |singular, builder|
  builder.literal!(singular.name + "s")
end
 # [SINGULAR] -> ...
 
builder.derivation! :key, :value do |key, value, builder|
  builder.pair(key, value)
end
 # [KEY, VALUE] -> ...
```

Variables can be conditional, in which case they are specified by passing a block:

```ruby
builder.variable!(:method) { |literal| literal.name =~ /^find_by_/ } # => METHOD?
builder.greedy_variable!(:pairs) { |literals| literals.size.even? } #=> PAIRS+?
```

#### Shorthands

The builder provides a method missing shorthand for constructing literals, variables and greedy variables:

```ruby
builder.succ # => succ
builder._n # => N 
builder._n :greedy # => N+
```

Conditional variables can also be constructed using this shorthand:

```ruby
builder._method { |literal| literal.name =~ /^find_by_/ } #=> METHOD?
builder._pairs(:greedy) { |literal| literal.name =~ /^find_by_/ } #=> PAIRS+?
```

#### Coercion of non-terms to literals

When constructing a literal, the builder ensures that any children are converted to literals if they are not already a term:

```ruby
builder.literal!(:add, :x, :y) # => add(x, y)
builder.add(:x, :y) # => add(x, y)
```

Without automatic coercion, the statements above would be written as follows. Note that they are more verbose:

```ruby
builder.literal!(:add, builder.literal!(:x), builder.literal!(:y)) # => add(x, y)
builder.add(builder.x, builder.y) # => add(x, y)
```

Note that coercion isn't necessary (and isn't applied) when the children of a literal are already terms:

```ruby
builder.literal!(:add, builder.variable!(:n), builder.variable!(:m)) # => add(N, M)
builder.add(builder._n, builder._m) # => add(N, M)
```

### Practical examples    

#### Rewriting Ruby programs
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