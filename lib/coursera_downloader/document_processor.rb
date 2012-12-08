require "nokogiri"

module CourseraDownloader
  class DocumentProcessor
    attr_reader :resource_urls, :document

    def initialize(document, store, policy)
      @document = document
      @store = store
      @policy = policy
      @resource_urls = Set.new
    end

    def process
      if @document.is_html?
        @document.body = process_html(@document.body)
      elsif @document.is_css?
        @document.body = process_css(@document.body)
      end
    end

    private

    def process_html(html)
      doc = Nokogiri::HTML(html)

      urls = Set.new
      doc.css("a, img, script, link").each do |element|
        url = element.attr("href") || element.attr("src")

        next if !url || url.length == 0 || url[0] == "#"

        url = URI.parse(url)
        url = normalize_resource_url(url)
        next if !@policy.allowed_url?(url)

        urls << url unless urls.include?(url)

        path = @store.relative_resource_path(@document.uri, url, true)
        if element.attr("href")
          element["href"] = path
        elsif element.attr("src")
          element["src"] = path
        end
      end

      doc.xpath("//*[@style]").each do |element|
        element["style"] = process_css(element.attr("style"))
      end

      @resource_urls += urls

      doc.to_s
    end

    def process_css(css)
      matches = css.scan(/url\(((")([^"]*)"|(')([^']*)'|[^\)]*)\)/)

      urls = Set.new
      matches.each do |match|
        quote = match[1] || match[3]
        raw_url = match[2] || match[4] || match[0]

        next if !raw_url || raw_url.length == 0

        url = URI.parse(raw_url)
        url = normalize_resource_url(url)
        next if !@policy.allowed_url?(url)

        urls << url unless urls.include?(url)

        path = @store.relative_resource_path(@document.uri, url, true)
        css.gsub!("url(#{quote}#{raw_url}#{quote})", "url('#{path}')")
      end

      @resource_urls += urls

      css
    end

    def normalize_resource_url(resource_url)
      unless resource_url.host
        URI.join(@document.uri, resource_url).to_s
      else
        resource_url.to_s
      end
    end
  end
end
