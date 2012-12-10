require "uri"

module CourseraDownloader
  class Document
    attr_reader :url, :content_type
    attr_accessor :body

    def initialize(url, body, content_type)
      @url = url
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
