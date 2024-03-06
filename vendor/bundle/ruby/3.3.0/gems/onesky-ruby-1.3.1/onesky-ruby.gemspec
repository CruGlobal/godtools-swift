# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'onesky/version'

Gem::Specification.new do |spec|
  spec.name          = "onesky-ruby"
  spec.version       = Onesky::VERSION
  spec.authors       = ["Victor Lam"]
  spec.email         = ["victorebox@yahoo.com.hk"]
  spec.summary       = "To interact with OneSky Platform API"
  spec.description   = "Ruby wrapper for OneSky API"
  spec.homepage      = "http://github.com/onesky/onesky-ruby"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 3.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.5.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
