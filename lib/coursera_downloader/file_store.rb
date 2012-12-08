require "fileutils"
require "cgi"
require "uri"

module CourseraDownloader
  class FileStore
    def path(url, path_in_source = false)
      uri = URI.parse(url)

      path = uri.path
      dir_name = File.dirname(path)
      extension = File.extname(path)
      base_name = File.basename(path, extension)

      extension = ".html" unless extension.length > 0

      if uri.query
        query = "?#{uri.query}"
        query = CGI.escape(query)
        query = CGI.escape(query) if path_in_source
      else
        query = ""
      end

      store_dir = File.join(uri.host, dir_name)
      file_path = File.join(store_dir, "#{base_name}#{query}#{extension}")

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

    def write(url, body)
      store_dir, file_path = path(url)

      FileUtils.mkdir_p(store_dir)

      File.open(file_path, "wb") do |file|
        file.write(body)
      end
    end
  end
end
