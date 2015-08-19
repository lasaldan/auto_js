Gem::Specification.new do |s|
  s.name        = 'auto_js'
  s.version     = '1.0.1'
  s.date        = '2015-07-21'
  s.summary     = "Auto-executes javascript based on current view"
  s.description = "Easily organizes a project's custom javascript and executes appropriate snippits automatically. Turbolinks compatible. Fills the gap between rails default javascript management and a full front end framework."
  s.authors     = ["Daniel Fuller"]
  s.email       = 'lasaldan@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/lasaldan/auto_js'
  s.license     = 'MIT'
end
