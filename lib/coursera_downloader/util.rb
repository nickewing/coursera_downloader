require "cgi"

module CourseraDownloader
  module Util
    def self.path_relative_to_path(target_path, path)
      target_dirs = target_path.split("/")
      dirs = path.split("/")

      while target_dirs.length > 1 && target_dirs[0] == dirs[0]
        target_dirs.shift
        dirs.shift
      end

      File.join(Array.new(target_dirs.length - 1, "..") + dirs)
    end

    def self.escape_path(path)
      path.split("/").map{|e| CGI.escape(e)}.join("/")
    end
  end
end
