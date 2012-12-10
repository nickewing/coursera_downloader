all_files = File.expand_path("coursera_downloader/*", File.dirname(__FILE__))
Dir[all_files].each do |file|
  require file
end
