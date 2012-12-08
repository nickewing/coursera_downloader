require "set"

module CourseraDownloader
  class Downloader
    def initialize(curl, policy, store)
      @curl = curl
      @queue = []
      @enqueued = Set.new # all URLs that have been ever enqueued during this run
      @store = store
      @policy = policy
    end

    def get(url)
      enqueue_unless_completed(url)
      fetch_all
    end

    private

    def fetch_one(url)
      puts "Downloading #{url}"

      document = get_url(url)

      if document.is_html? || document.is_css?
        processor = DocumentProcessor.new(document, @store, @policy)
        processor.process

        processor.resource_urls.map do |resource_url|
          enqueue_unless_completed(resource_url)
        end

        body = processor.document.body
      end

      @store.write(document)
    end

    def fetch_all
      while @queue.length > 0
        url = @queue.shift
        fetch_one(url)
      end
    end

    def get_url(url)
      @curl.url = url
      @curl.http_get

      # TODO: use real logger
      puts "WARN: Failed to get URL '#{url}'.  Response code #{@curl.response_code}" unless @curl.response_code == 200

      Document.new(url, @curl.body_str, @curl.content_type)
    end

    def enqueue_unless_completed(url)
      # _, file_path = @store.path(url)

      if !@enqueued.include?(url)# && !File.exists?(file_path)
        @enqueued << url
        @queue.push(url)
      end
    end

  end
end
