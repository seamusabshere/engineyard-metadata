require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "engineyard-metadata #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rspec/core/rake_task'

# thanks bundler
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-fs --color)
  # t.ruby_opts  = %w(-w)
end

task :default => :spec
