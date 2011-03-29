# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "png-gradient/version"

Gem::Specification.new do |s|
  s.name        = "png-gradient"
  s.version     = Png::Gradient::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'Jonathan Tropper'
  s.email       = 'tropperstyle@gmail.com'
  s.homepage    = ""
  s.summary     = 'PNG Gradient Generator'
  s.description = 'Easily create linear png gradients'

  s.rubyforge_project = "png-gradient"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('sinatra')
  s.add_dependency('rmagick')
end
