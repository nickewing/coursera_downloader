require "logger"
require "set"
require "yaml"
require "uri"

module CourseraDownloader
  class Downloader
    MAX_BATCH_SIZE = 10

    attr_writer :logger

    def initialize(cookie_file, policy, store)
      @cookie_file = cookie_file
      @queue = []
      @enqueued = Set.new # all URLs that have been ever enqueued during this run
      @store = store
      @policy = policy

      read_state
    end

    def get(url)
      url = URI.parse(url)
      enqueue_new_url(url)
      fetch_all
      logger.info("Downloaded #{@enqueued.length} total files")
    end

    def logger
      unless @logger
        @logger = Logger.new(STDOUT)
        @logger.formatter = LogFormatter.new
      end

      @logger
    end

    private

    def state_save_path
      File.join(@store.containing_dir, "manifest.yml")
    end

    def write_state
      if File.exists?(@store.containing_dir)
        File.open(state_save_path, "wb") do |file|
          state = {
            :queue => @queue,
            :enqueued => @enqueued.to_a
          }
          file.write(YAML::dump(state))
        end
      end
    end

    def read_state
      if File.exists?(state_save_path)
        saved_state = YAML::load(File.read(state_save_path))

        @queue = saved_state[:queue]
        @enqueued = Set.new(saved_state[:enqueued])
      end
    end

    def handle_document(document)
      if document.is_html? || document.is_css?
        processor = DocumentProcessor.new(document, @store, @policy)
        processor.process

        processor.resource_urls.map do |resource_url|
          enqueue_new_url(resource_url)
        end

        body = processor.document.body
      end

      @store.write(document)
    end

    def fetch_all
      begin
        interrupted = false
        trap("INT") do
          interrupted = true
          show_interrupt_message
        end

        while @queue.length > 0 && !interrupted
          batch = @queue.shift(MAX_BATCH_SIZE)
          fetch_batch(batch)
        end

        trap("INT", "DEFAULT")
      ensure
        write_state
      end
    end

    def fetch_batch(batch)
      m = Curl::Multi.new

      batch.each do |url|
        curl = Curl::Easy.new(url.to_s) do |curl|
          curl.enable_cookies = true
          curl.cookiefile = @cookie_file.path
          curl.cookiejar = @cookie_file.path
          curl.follow_location = true

          curl.on_complete do |result|
            begin
              if result.response_code == 200
                logger.info("Downloaded: #{url}")

                content_type = result.content_type
                content_type.force_encoding("ASCII") if content_type.respond_to?(:force_encoding)

                document = Document.new(url, result.body_str, content_type)
                handle_document(document)
              else
                logger.warn("Failed to get URL '#{url}'.  Response code #{result.response_code}")
              end
            rescue => e
              logger.error(e.message + "\n  " + e.backtrace.join("\n  "))
            end
          end
        end

        m.add(curl)
      end

      m.perform
    end

    def enqueue_new_url(url)
      if !@enqueued.include?(url)
        @enqueued << url
        @queue.push(url)
      end
    end

    def show_interrupt_message
      return if @interrupt_message_shown

      logger.warn("Finishing current download batch.")
      logger.warn("This download can be resumed by rerunning the same command.")

      @interrupt_message_shown = true
    end

  end
end
