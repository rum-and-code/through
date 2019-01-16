
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "through/version"

Gem::Specification.new do |spec|
  spec.name          = "through"
  spec.version       = Through::VERSION
  spec.authors       = ["Nicolas Boisvert"]
  spec.email         = ["nicolas@rumandcode.io"]

  spec.summary       = %q{A gem that helps you write pipeline}
  spec.description   = %q{This gem has no official purpose, it's a pipeline, pipe anything you want through it from string to ActiveRecord query}
  spec.homepage      = "https://github.com/rum-and-code/through"
  spec.license       = "MIT"

  spec.files         = ["lib/through.rb"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
