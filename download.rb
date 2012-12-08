VERBOSE = false
COOKIE_FILE = "cookies.txt"

$: << File.dirname(__FILE__)

require "lib/coursera_downloader"

course_name = ARGV[0]
email = ARGV[1]
password = ARGV[2]

course = CourseraDownloader::Course.new(course_name)

puts "Logging in"
course.login(email, password)

course.get_index
