# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "engineyard-metadata/version"

Gem::Specification.new do |s|
  s.name        = "engineyard-metadata"
  s.version     = EY::Metadata::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Seamus Abshere"]
  s.email       = ["seamus@abshere.net"]
  s.homepage    = "https://github.com/seamusabshere/engineyard-metadata"
  s.summary     = %Q{Make your EngineYard AppCloud (Amazon EC2) instances aware of each other.}
  s.description = %Q{Pulls metadata from EC2 and EngineYard so that your EngineYard AppCloud (Amazon EC2) instances know about each other.}

  s.rubyforge_project = "engineyard-metadata"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,fengineyard-metadataures}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'activesupport', '>=2.3.4'
  s.add_dependency 'nap', '>=0.4'
  s.add_dependency 'eat', '>=0.0.5'
end
