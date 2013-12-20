Gem::Specification.new do |s|
  s.name        = 'stylr'
  s.executables << 'stylr'
  s.version     = '0.0.1'
  s.date        = '2013-12-20'
  s.summary     = 'stylr - enforcing Ruby coding style standards'
  s.description = 'An attempt at enforcing https://github.com/styleguide/ruby'
  s.authors     = ['Mark Billie']
  s.email       = 'mbillie@gmail.com'
  s.homepage    = 'http://github.com/yaaase/stylr.git'
  s.license     = 'Apache'
  s.files       = `git ls-files`.split(/\n/)

  s.add_runtime_dependency 'main', '~> 5.2.0'
  s.add_development_dependency 'rspec', '~> 2.14.3'
end
