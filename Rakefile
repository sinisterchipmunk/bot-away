ENV['BUNDLE_GEMFILE'] ||= File.expand_path("gemfiles/Gemfile.rails-3.1.x", File.dirname(__FILE__))
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec
