# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metamorpher/version'

Gem::Specification.new do |spec|
  spec.name          = "metamorpher"
  spec.version       = Metamorpher::VERSION
  spec.authors       = ["Louis Rose"]
  spec.email         = ["louis.rose@york.ac.uk"]
  spec.description   = %q{Provides structures that support program transformations, such as refactoring or program mutation.}
  spec.summary       = %q{A term rewriting library for transforming (Ruby) programs}
  spec.homepage      = "https://github.com/mutiny/metamorpher"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "attributable", "~> 0.1.0"
  spec.add_runtime_dependency "parser", "~> 2.2.2"
  spec.add_runtime_dependency "unparser", "~> 0.2.4"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.4.2"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4.6"
  spec.add_development_dependency "rubocop", "~> 0.33.0"
end
