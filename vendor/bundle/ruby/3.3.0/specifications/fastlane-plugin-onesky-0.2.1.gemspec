# -*- encoding: utf-8 -*-
# stub: fastlane-plugin-onesky 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "fastlane-plugin-onesky".freeze
  s.version = "0.2.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Kiedrowski".freeze]
  s.date = "2017-09-06"
  s.email = "daniel@levire.com".freeze
  s.homepage = "https://github.com/danielkiedrowski/fastlane-plugin-onesky".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.5.3".freeze
  s.summary = "Helps to update the translations of your app using the OneSky service.".freeze

  s.installed_by_version = "3.5.3".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<onesky-ruby>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<fastlane>.freeze, [">= 1.105.3".freeze])
end
