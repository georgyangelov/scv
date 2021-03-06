# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'scv/version'

Gem::Specification.new do |spec|
  spec.name        = 'scvcs'
  spec.version     = SCV::VERSION
  spec.authors     = ["Georgy Angelov"]
  spec.email       = ["georgyangelov@gmail.com"]
  spec.homepage    = "http://github.com/stormbreakerbg/scv"
  spec.summary     = "A Ruby gem designed implementing a simple Git-like version control system on top of vcs-toolkit."
  spec.description = ""
  spec.license     = "MIT"

  spec.add_runtime_dependency "vcs_toolkit"
  spec.add_runtime_dependency "gli"
  spec.add_runtime_dependency "colorize"
  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "rack"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "fuubar"
  spec.add_development_dependency "webmock"

  spec.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  spec.executables  = ['scv']
  spec.require_path = 'lib'
end