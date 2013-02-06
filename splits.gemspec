# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'splits/version'

Gem::Specification.new do |gem|
  gem.name          = "splits"
  gem.version       = Splits::VERSION
  gem.authors       = ["Chase Stubblefield"]
  gem.email         = ["chasestubblefield@gmail.com"]
  gem.description   = %q{Speedrun timer}
  gem.summary       = %q{Speedrun timer}
  gem.homepage      = "https://github.com/chasestubblefield/splits"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('colorize')
  gem.add_development_dependency('rake')
end
