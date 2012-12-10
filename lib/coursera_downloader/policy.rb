module CourseraDownloader
  class Policy
    WHITELIST_PATTERNS = [
      /^https?:\/\/class\.coursera\.org\/[^\/]+\//,
      /^https?:\/\/[^\.]+\.s3\.amazonaws\.com/,
      /^https?:\/\/s3\.amazonaws\.com/,
      /^https?:\/\/[^\.]+\.cloudfront\.net/
    ]

    BLACKLIST_PATTERNS = [
      /^http:?:\/\/s3\.amazonaws\.com\/mlclass-resources\/software/,
      /\.(exe|dmg)(\?.*)?$/
    ]

    DISALBE_PATTERNS = [
      /^https?:\/\/class\.coursera\.org\/[^\/]+\/quiz/,
      /^https?:\/\/class\.coursera\.org\/[^\/]+\/forum/,
      # /^https?:\/\/class\.coursera\.org\/[^\/]+\/lecture/,
      # /^https?:\/\/class\.coursera\.org\/[^\/]+\/wiki/,
      /^https?:\/\/class\.coursera\.org\/[^\/]+\/class\/preferences/,
      /^https:\/\/class.coursera.org\/[^\/]+\/forum\/thread?.*view=.*/,
      /^https:\/\/class.coursera.org\/[^\/]+\/forum\/tag?.*view=.*/,
      /^https:\/\/class.coursera.org\/[^\/]+\/forum\/list?.*view=.*/,
      /^https:\/\/class.coursera.org\/[^\/]+\/forum\/toggle/,
      /^https:\/\/class.coursera.org\/[^\/]+\/forum\/tag_modify/,
      /^https?:\/\/class\.coursera\.org\/[^\/]+\/quiz\/start/,
      /^https?:\/\/class\.coursera\.org\/[^\/]+\/generic\/apply_late_days/,
      /^https?:\/\/class\.coursera\.org\/[^\/]+\/auth\/logout/,
    ]

    def url_action(url)
      return :none if !url || (url.scheme && !(url.scheme != "http" || url.scheme != "https"))

      url = url.to_s
      return :disable if disable_url?(url)
      return :download if download_url?(url)
    end

    private

    def download_url?(url)
      BLACKLIST_PATTERNS.each do |pattern|
        return false if url.match(pattern)
      end

      match = false
      WHITELIST_PATTERNS.each do |pattern|
        match = true if url.match(pattern)
      end

      match
    end

    def disable_url?(url)
      DISALBE_PATTERNS.each do |pattern|
        return true if url.match(pattern)
      end

      false
    end
  end
end
