# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bot-away/version"

Gem::Specification.new do |s|
  s.name        = "bot-away"
  s.version     = BotAway::VERSION
  s.authors     = ["Colin MacKenzie IV"]
  s.email       = ["sinisterchipmunk@gmail.com"]
  s.homepage    = "http://github.com/sinisterchipmunk/bot-away"
  s.summary     = %q{Unobtrusively detects form submissions made by spambots, and silently drops those submissions.}
  s.description = %q{Unobtrusively detects form submissions made by spambots, and silently drops those submissions.}

  s.rubyforge_project = "bot-away"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc",
    "History.txt"
  ]

  s.add_runtime_dependency('actionpack', ">= 2.3.5")
  s.add_runtime_dependency('sc-core-ext', ">= 1.1.1")
  s.add_development_dependency 'rake', '~> 0.9.2'
end
