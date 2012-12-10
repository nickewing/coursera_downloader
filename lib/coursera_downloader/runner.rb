require "logger"

module CourseraDownloader
  class Runner
    def self.run
      if ARGV.length < 4
        $stderr.puts "Usage:\n  coursera_downloader course-identifier email password destination-directory [policy-file]"
        Process.exit(1)
      end

      course_name = ARGV[0]
      email = ARGV[1]
      password = ARGV[2]
      file_store_dir = ARGV[3]

      logger = Logger.new(STDOUT)
      logger.formatter = LogFormatter.new

      course = Course.new(course_name)
      if course.login(email, password)
        policy_file = ARGV[4] || File.expand_path("../download_policy.yml", File.dirname(__FILE__))
        policy = Policy.new(policy_file)
        store = FileStore.new(file_store_dir)
        downloader = Downloader.new(course.cookie_file, policy, store, logger)
        downloader.get(course.index_url)

        _, index_store_path = store.path(course.index_url)
        logger.info("The course index can be found at #{index_store_path}")
      else
        logger.error("Failed to login.")
      end
    end
  end
end
