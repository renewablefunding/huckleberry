# coding: utf-8
lib = File.expand_path('./lib')
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

  spec.files         = Dir.glob("{bin,lib,helpers,config,exe}/**/*")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "mail"
  spec.add_runtime_dependency "mailcatcher"
  spec.add_runtime_dependency "launchy"
end
