require "fileutils"
require "cgi"

module CourseraDownloader
  class FileStore
    attr_reader :containing_dir

    def initialize(containing_dir)
      @containing_dir = containing_dir
    end

    def path(url, path_in_source = false)
      path = url.path
      dir_name = File.dirname(path)
      extension = File.extname(path)
      base_name = File.basename(path, extension)

      extension = ".html" unless extension.length > 0

      if url.query
        query = "?#{url.query}"
        query = CGI.escape(query)
      else
        query = ""
      end

      store_dir = File.join(@containing_dir, url.host, dir_name)
      store_dir = Util.escape_path(store_dir) if path_in_source

      file_name = "#{base_name}#{query}#{extension}"
      file_name = Util.escape_path(file_name) if path_in_source

      file_path = File.join(store_dir, file_name)

      [store_dir, file_path]
    end

    def relative_resource_path(containing_url, resource_url, path_in_source = true)
      _, containing_path = path(containing_url, path_in_source)
      _, resource_path = path(resource_url, path_in_source)

      Util.path_relative_to_path(containing_path, resource_path)
    end

    def write(document)
      store_dir, file_path = path(document.url)

      FileUtils.mkdir_p(store_dir)

      File.open(file_path, "wb") do |file|
        file.write(document.body)
      end
    end

  end
end
