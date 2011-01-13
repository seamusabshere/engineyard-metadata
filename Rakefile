require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "engineyard-metadata"
    gem.summary = %Q{Make your EngineYard AppCloud (Amazon EC2) instances aware of each other.}
    gem.description = %Q{Pulls metadata from EC2 and EngineYard so that your EngineYard AppCloud (Amazon EC2) instances know about each other.}
    gem.email = "seamus@abshere.net"
    gem.homepage = "http://github.com/seamusabshere/engineyard-metadata"
    gem.authors = ["Seamus Abshere"]
    gem.add_dependency 'activesupport', '>=2.3.4'
    gem.add_dependency 'nap', '>=0.4'
    gem.add_dependency 'eat'
    gem.add_development_dependency "fakeweb"
    gem.add_development_dependency "fakefs"
    gem.add_development_dependency "rspec", "~>2"
    gem.executables = ['ey_ssh_aliases']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "engineyard-metadata #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
