require "set"

module CourseraDownloader
  class Downloader
    def initialize(curl)
      @curl = curl
      @queue = []
      @completed = Set.new
      @store = FileStore.new
    end

    def get(url)
      @queue.push(url)
      fetch_all
    end

    private

    def fetch_one(url)
      puts "Downloading #{url}"
      @completed << url

      body, is_html = get_url(url)

      if is_html
        processor = DocumentProcessor.new(url, body, @store)
        processor.process

        processor.resource_urls.map do |resource_url|
          enqueue_unless_completed(resource_url)
        end

        body = processor.body
      end

      @store.write(url, body)
    end

    def fetch_all
      while @queue.length > 0
        url = @queue.pop
        fetch_one(url)
      end
    end

    def get_url(url)
      @curl.url = url
      @curl.http_get

      # TODO: use real logger
      puts "WARN: Failed to get URL '#{url}'.  Response code #{@curl.response_code}" unless @curl.response_code == 200

      is_html = @curl.content_type =~ /text\/html/
      [@curl.body_str, is_html]
    end

    def enqueue_unless_completed(url)
      _, file_path = @store.path(url)

      if !@completed.include?(url)# && !File.exists?(file_path)
        @queue.push(url)
      end
    end

  end
end
