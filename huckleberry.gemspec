# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'huckleberry/version'

Gem::Specification.new do |spec|
  spec.name          = "huckleberry"
  spec.version       = Huckleberry::VERSION
  spec.authors       = ["Adam"]
  spec.email         = ["amcfadden@renewfund.com"]

  spec.summary       = %q{A script written in ruby to allow parsing of logs.}
  spec.description   = %q{A script written in ruby to allow parsing of logs.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["."]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "mail"
  spec.add_runtime_dependency "mailcatcher"
end