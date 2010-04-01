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
