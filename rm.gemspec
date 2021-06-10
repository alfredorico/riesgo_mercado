$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rm/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rm"
  s.version     = Rm::VERSION
  s.authors     = ["Alfredo E. Rico Moros"]
  s.email       = ["alfredorico@gmail.com"]
  s.homepage    = "http://example.com"
  s.summary     = "Módulo de Riesgo de Mercado (RM)"
  s.description = "Módulo de Riesgo de Mercado (RM)."
  s.license     = "MIT"
  s.files = Dir["{app,config,db,lib,rgloader}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc","VERSION.txt","*.lic"]
  s.add_dependency "rinruby","2.0.3"  
  s.add_dependency "descriptive_statistics", "2.5.1"
  s.add_dependency "rubyXL","3.1.0"
end
