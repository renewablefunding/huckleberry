# coding: utf-8
lib = File.expand_path('./lib')
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'huckleberry/version'

Gem::Specification.new do |spec|
  spec.name          = "huckleberry"
  spec.version       = Huckleberry::VERSION
  spec.authors       = ["Adam McFadden"]
  spec.email         = ["mcfadden.113@gmail.com"]

  spec.summary       = %q{A ruby script that parses logfiles using regex.}
  spec.description   = %q{A ruby script that parses logfiles using regex. Huckleberry parses logs by having the user define what lines should be excluded and reporting back when non-ignored lines are found.}
  spec.homepage      = "https://github.com/renewablefunding/huckleberry"
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib,helpers,exe}/**/*")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "mail"
  spec.add_runtime_dependency "to_regexp"
  spec.add_runtime_dependency "mailcatcher"
  spec.add_runtime_dependency "launchy"
end
