require "nokogiri"

module CourseraDownloader
  class DocumentProcessor

    def initialize(url, body, store, policy)
      @url = url
      @body = body
      @store = store
      @policy = policy
    end

    attr_reader :body, :resource_urls

    def process
      doc = Nokogiri::HTML(body)

      urls = Set.new
      doc.css("a, img, script, link").each do |element|
        url = element.attr("href") || element.attr("src")

        next if !url || url.length == 0 || url[0] == "#" || urls.include?(url)

        url = URI.parse(url)
        url = normalize_resource_url(url)
        next unless @policy.allowed_url?(url)

        urls << url

        path = @store.relative_resource_path(@url, url, true)
        if element.attr("href")
          element["href"] = path
        elsif element.attr("src")
          element["src"] = path
        end
      end

      @body = doc.to_s
      @resource_urls = urls
    end

    private

    def normalize_resource_url(resource_url)
      unless resource_url.host
        URI.join(@url, resource_url).to_s
      else
        resource_url.to_s
      end
    end
  end
end
