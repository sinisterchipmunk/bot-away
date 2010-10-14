require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'bot-away'
    gem.summary = %Q{Unobtrusively detects form submissions made by spambots, and silently drops those submissions.}
    gem.description = %Q{Unobtrusively detects form submissions made by spambots, and silently drops those submissions.}
    gem.email = "sinisterchipmunk@gmail.com"
    gem.homepage = "http://www.thoughtsincomputation.com"
    gem.authors = ["Colin MacKenzie IV"]
    gem.add_dependency "actionpack", ">= 2.3.5"
    gem.add_dependency "sc-core-ext", ">= 1.1.1"
    gem.add_development_dependency "jeweler", ">= 1.4.0"
    gem.add_development_dependency "rspec", ">= 1.3.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

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

task :spec => :check_dependencies
task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?("VERSION") ? File.read("VERSION") : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bot-away #{version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

=begin
require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/bot-away'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'bot-away' do
  self.developer 'Colin MacKenzie IV', 'sinisterchipmunk@gmail.com'
  self.extra_deps         = [['actionpack','>= 2.3.5'],['sc-core-ext','>= 1.1.1']]
  self.readme_file = "README.rdoc"
end

Rake::RDocTask.new(:docs) do |rdoc|
  files = ['README.rdoc', # 'LICENSE', 'CHANGELOG',
           'lib/**/*.rb', 'doc/**/*.rdoc']#, 'spec/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = 'README.rdoc'
  rdoc.title = 'Bot-Away Documentation'
  #rdoc.template = '/path/to/gems/allison-2.0/lib/allison'
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers' << '--inline-source'
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
=end
