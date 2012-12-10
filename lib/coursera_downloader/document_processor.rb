require "nokogiri"

module CourseraDownloader
  class DocumentProcessor
    DISABLED_HREF = "javascript:alert('Link disabled during download.');"

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

        url = normalize_url(url)

        case @policy.url_action(url)
        when :disable
          disable_html_element(element)
        when :download
          urls << url unless urls.include?(url)
          localize_element(element, url)
        end
      end

      doc.xpath("//*[@style]").each do |element|
        element["style"] = process_css(element.attr("style"))
      end

      @resource_urls += urls

      doc.to_s
    end

    def localize_element(element, url)
      path = @store.relative_resource_path(@document.url, url, true)
      if element.attr("href")
        element["href"] = path
      elsif element.attr("src")
        element["src"] = path
      end
    end

    def disable_html_element(element)
      if element.attr("href")
        element["href"] = DISABLED_HREF
      elsif element.attr("src")
        element.remove
      end
    end

    def process_css(css)
      matches = css.scan(/url\(((")([^"]*)"|(')([^']*)'|[^\)]*)\)/)

      urls = Set.new
      matches.each do |match|
        quote = match[1] || match[3]
        raw_url = match[2] || match[4] || match[0]

        # puts ">>>> #{raw_url}"
        url = normalize_url(raw_url)

        # p @policy.url_action(url)

        case @policy.url_action(url)
        when :disable
          css.gsub!("url(#{quote}#{raw_url}#{quote})", "url()")
        when :download
          urls << url unless urls.include?(url)
          path = @store.relative_resource_path(@document.url, url, true)
          css.gsub!("url(#{quote}#{raw_url}#{quote})", "url('#{path}')")
        end
      end

      @resource_urls += urls

      css
    end

    def normalize_url(url)
      return nil if !url || url.length == 0

      begin
        url = URI.parse(url)
      rescue URI::InvalidURIError => e
        return nil
      end

      if url.host
        url = url
      else
        url = URI.join(@document.url, url)
      end

      url
    end
  end
end
