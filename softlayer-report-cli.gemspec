# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'softlayer/cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'softlayer-report-cli'
  spec.version       = SoftLayer::CLI_VERSION
  spec.authors       = ['Renier Morales']

  spec.summary       = %q{SoftLayer Report Command Line Interface}
  spec.description   = %q{SoftLayer Report Command Line Interface.}
  spec.homepage      = 'https://github.com/renier/softlayer-report-cli'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'softlayer_api', '~> 3.1.0'
  spec.add_dependency 'thor', '~> 0.19.1'
  spec.add_dependency 'terminal-table', '~> 1.5.2'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
