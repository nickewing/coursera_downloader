require "uri"

module CourseraDownloader
  class Document
    attr_reader :uri, :content_type
    attr_accessor :body

    def initialize(url, body, content_type)
      @uri = URI.parse(url)
      @body = body
      @content_type = content_type
    end

    def is_html?
      content_type =~ /text\/html/
    end

    def is_css?
      content_type =~ /text\/css/
    end

    def is_javascript?
      content_type =~ /javascript/
    end
  end
end
