require "logger"
require "colored"

module CourseraDownloader
  class LogFormatter < ::Logger::Formatter
    def call(severity, time, progname, msg)
      case severity
      when "INFO"
        severity = severity.green
      when "WARN"
        severity = severity.yellow
      when "ERROR"
        severity = severity.red
      end

      "#{severity}: #{msg}\n"
    end
  end
end
