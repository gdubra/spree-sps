$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sps/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sps"
  s.version     = Sps::VERSION
  s.authors     = ["Gaston Dubra"]
  s.email       = ["gaston.dubra@gmail.com"]
  s.summary     = "Sps gateway"
  s.files        = Dir['MIT-LICENSE', 'README.rdoc', 'app/**/*', 'config/**/*', 'lib/**/*', 'script/**/*']
  
  s.add_dependency 'spree_core'
end
