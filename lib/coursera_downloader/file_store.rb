require "fileutils"
require "cgi"

module CourseraDownloader
  class FileStore
    def initialize(containing_dir)
      @containing_dir = containing_dir
    end

    def path(uri, path_in_source = false)
      uri = URI.parse(uri) unless uri.is_a?(URI)

      path = uri.path
      dir_name = File.dirname(path)
      extension = File.extname(path)
      base_name = File.basename(path, extension)

      extension = ".html" unless extension.length > 0

      if uri.query
        query = "?#{uri.query}"
        query = CGI.escape(query)
      else
        query = ""
      end

      store_dir = File.join(@containing_dir, uri.host, dir_name)
      store_dir = escape_path(store_dir) if path_in_source

      file_name = "#{base_name}#{query}#{extension}"
      file_name = escape_path(file_name) if path_in_source

      file_path = File.join(store_dir, file_name)

      [store_dir, file_path]
    end

    def relative_resource_path(containing_url, resource_url, path_in_source = true)
      _, containing_path = path(containing_url, path_in_source)
      _, resource_path = path(resource_url, path_in_source)

      containing_dirs = containing_path.split("/")
      resource_dirs = resource_path.split("/")

      while containing_dirs.length > 1 && containing_dirs[0] == resource_dirs[0]
        containing_dirs.shift
        resource_dirs.shift
      end

      ("../" * (containing_dirs.length - 1)) + File.join(resource_dirs)
    end

    def write(document)
      store_dir, file_path = path(document.uri)

      FileUtils.mkdir_p(store_dir)

      File.open(file_path, "wb") do |file|
        file.write(document.body)
      end
    end

    private

    def escape_path(path)
      path.split("/").map{|e| CGI.escape(e)}.join("/")
    end
  end
end
