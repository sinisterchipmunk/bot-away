ENV['BUNDLE_GEMFILE'] ||= File.expand_path("gemfiles/Gemfile.rails-3.1.x", File.dirname(__FILE__))
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

desc  "Run all specs with rcov"
begin
  require 'rcov'
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/,features\/,lib\/bot-away\/test_case\/}
  end
rescue LoadError
  task :rcov do
    raise "Install rcov first: gem install rcov"
  end
end

task :default => :spec
