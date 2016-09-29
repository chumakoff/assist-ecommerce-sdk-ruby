# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'assist/version'

Gem::Specification.new do |spec|
  spec.name          = "assist-ruby-sdk"
  spec.version       = Assist::VERSION
  spec.authors       = ["Anton Chumakov"]
  spec.email         = ["anton@chumakoff.com"]

  spec.summary       = %q{Assist Online Payment System SDK for Ruby.}
  spec.description   = %q{The Assist Ruby SDK provides Ruby APIs to create, process and manage payments.}
  spec.homepage      = "https://github.com/chumakoff/assist-ecommerce-sdk-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 2.1"
end
