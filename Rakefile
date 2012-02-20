require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'

require 'yard'
YARD::Rake::YardocTask.new

require 'rspec/core/rake_task'

# thanks bundler
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-fs --color)
  # t.ruby_opts  = %w(-w)
end

task :default => :spec
