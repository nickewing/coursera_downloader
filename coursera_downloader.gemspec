Gem::Specification.new do |s|
  s.name         = "coursera_downloader"
  s.version      = "0.1.0"
  s.authors      = ["Nick Ewing"]
  s.email        = ""
  s.homepage     = ""
  s.summary      = ""
  s.description  = "#{s.summary}."

  s.files        = Dir["{lib/**/*,[A-Z]*}"]
  s.platform     = Gem::Platform::RUBY
  s.require_path = "lib"
  s.rubyforge_project = "[none]"

  s.add_dependency "curb",  "~> 0.8"
  s.add_dependency "nokogiri",  "~> 1.5"
end
