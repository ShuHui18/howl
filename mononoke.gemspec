
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mononoke/version'

Gem::Specification.new do |spec|
  spec.name          = 'mononoke'
  spec.version       = Mononoke::VERSION
  spec.authors       = ['Shu Hui']
  spec.email         = ['shu.hui@blockchaintech.net.au']

  spec.summary       = 'Diagnostics Generator'
  spec.description   = 'Diagnostics Generator inclues db, rabbitmq, version, uptime checks'
  spec.homepage      = "https://github.com/blockchaintech-au/mononoke"
  spec.license       = 'MIT'

  spec.files         = Dir['**/*'].keep_if { |file| File.file?(file) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
