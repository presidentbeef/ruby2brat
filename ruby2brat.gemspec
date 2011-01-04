Gem::Specification.new do |s|
  s.name = %q{ruby2brat}
  s.version = "0.1.0"
  s.authors = ["Justin Collins"]
  s.summary = "Convert Ruby code to Brat code"
  s.description = "Ruby2Brat translates a subset of Ruby to roughly equivalent Brat code."
  s.homepage = "http://github.com/presidentbeef/ruby2brat"
  s.files = ["bin/ruby2brat", "README.md"]
  s.executables = ["ruby2brat"]
  s.add_dependency "ruby2ruby" 
end
