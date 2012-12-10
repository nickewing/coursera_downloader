Gem::Specification.new do |s|
  s.name         = "coursera_downloader"
  s.version      = "0.1.2"
  s.authors      = ["Nick Ewing"]
  s.email        = ""
  s.homepage     = "https://github.com/nickewing/coursera_downloader"
  s.summary      = "Download static versions of Coursera course websites."
  s.description  = "#{s.summary}."

  s.files        = `git ls-files`.split("\n").reject {|path| path =~ /\.gitignore$/ }
  s.executables  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.platform     = Gem::Platform::RUBY
  s.require_path = "lib"
  s.rubyforge_project = "[none]"

  s.add_dependency "curb",  "~> 0.8"
  s.add_dependency "nokogiri",  "~> 1.5"
  s.add_dependency "colored",  "~> 1.2"
end
