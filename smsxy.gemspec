# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smsxy/version'

Gem::Specification.new do |spec|
  spec.name          = "smsxy"
  spec.version       = SMSXY::VERSION
  spec.authors       = ["Jarred Sumner"]
  spec.email         = ["jarred@jarredsumner.com"]
  spec.description   = "SMS routing made easy"
  spec.summary       = "SMS routing made easy"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "twilio-ruby"
end
