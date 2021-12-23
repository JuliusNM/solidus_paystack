# frozen_string_literal: true

require_relative 'lib/solidus_paystack/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_paystack'
  spec.version = SolidusPaystack::VERSION
  spec.authors = ['Julius']
  spec.email = 'juliusngigim@gmail.com'

  spec.summary = 'solidus_paystack is an extension that adds support for using Paystack as a payment source in your Solidus store. It supports Paystack transactions.'
  spec.homepage = 'https://github.com/solidusio-contrib/solidus_paystack#readme'
  spec.license = 'BSD-3-Clause'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/solidusio-contrib/solidus_paystack'
  spec.metadata['changelog_uri'] = 'https://github.com/solidusio-contrib/solidus_paystack/blob/master/CHANGELOG.md'

  spec.required_ruby_version = Gem::Requirement.new('~> 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'active_model_serializers', '~> 0.10'
  spec.add_dependency 'httparty', '~> 0.18.1'
  spec.add_dependency 'solidus_core', ['>= 2.0.0', '< 4']
  spec.add_dependency 'solidus_support', '~> 0.5'

  spec.add_development_dependency 'solidus_dev_support', '~> 2.5'
end
