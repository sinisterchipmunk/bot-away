require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/bot-proof-forms'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'bot-proof-forms' do
  self.developer 'Colin MacKenzie IV', 'sinisterchipmunk@gmail.com'
  self.extra_deps         = [['action_controller','>= 2.3.5'],['action_view','>= 2.3.5'],['sc-core-ext','>= 1.1.1']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

require 'spec/rake/spectask'

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/home/*']
end

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
