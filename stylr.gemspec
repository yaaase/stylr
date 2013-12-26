# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stylr/version'

Gem::Specification.new do |spec|
  spec.name          = "stylr"
  spec.version       = Stylr::VERSION
  spec.authors       = ["Mark Billie"]
  spec.email         = ["mbillie1@gmail.com"]
  spec.description   = %q{An attempt at enforcing https://github.com/styleguide/ruby}
  spec.summary       = %q{stylr - enforcing Ruby coding style standards}
  spec.homepage      = "https://github.com/yaaase/stylr.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "main",    "~> 5.2", ">= 5.2.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
end
