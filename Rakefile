ENV['BUNDLE_GEMFILE'] ||= File.expand_path("gemfiles/rails3", File.dirname(__FILE__))
require 'bundler/gem_tasks'

require File.join(File.dirname(__FILE__), "spec/rspec_version")

if RSPEC_VERSION >= "2.0.0"
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
  end
else # Rake task for 1.3.x
  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
  end
  
  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
  end
end
