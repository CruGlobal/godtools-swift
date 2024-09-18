begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) { |t| t.verbose = false }

  task :default => :spec
rescue LoadError
  p "no rspec available"
end
