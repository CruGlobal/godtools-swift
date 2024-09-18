# -*- encoding: utf-8 -*-
# stub: cocoapods-core 1.15.2 ruby lib

Gem::Specification.new do |s|
  s.name = "cocoapods-core".freeze
  s.version = "1.15.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eloy Duran".freeze, "Fabio Pelosin".freeze]
  s.date = "2024-02-06"
  s.description = "The CocoaPods-Core gem provides support to work with the models of CocoaPods.\n\n It is intended to be used in place of the CocoaPods when the the installation of the dependencies is not needed.".freeze
  s.email = ["eloy.de.enige@gmail.com".freeze, "fabiopelosin@gmail.com".freeze]
  s.homepage = "https://github.com/CocoaPods/CocoaPods".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "The models of CocoaPods".freeze

  s.installed_by_version = "3.5.16".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0".freeze, "< 8".freeze])
  s.add_runtime_dependency(%q<nap>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<fuzzy_match>.freeze, ["~> 2.0.4".freeze])
  s.add_runtime_dependency(%q<algoliasearch>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<typhoeus>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<netrc>.freeze, ["~> 0.11".freeze])
  s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.8".freeze])
  s.add_runtime_dependency(%q<public_suffix>.freeze, ["~> 4.0".freeze])
  s.add_development_dependency(%q<bacon>.freeze, ["~> 1.1".freeze])
end
