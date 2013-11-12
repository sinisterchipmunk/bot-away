ENV['BUNDLE_GEMFILE'] ||= File.expand_path("gemfiles/Gemfile.rails-3.1.x", File.dirname(__FILE__))
require 'bundler/gem_tasks'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

task :default => :cucumber
