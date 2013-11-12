require 'bundler/gem_tasks'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

require 'rubocop/rake_task'
Rubocop::RakeTask.new do |t|
  t.fail_on_error = false
end

task :default => [ :cucumber, :rubocop ]
