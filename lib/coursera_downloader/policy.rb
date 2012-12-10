require "yaml"

module CourseraDownloader
  class Policy
    def initialize(file)
      @patterns = YAML::load(File.read(file))

      @patterns.each_pair do |group, patterns|
        @patterns[group] = patterns.map do |pattern|
          Regexp.new(pattern)
        end
      end
    end

    def url_action(url)
      return :none if !url || (url.scheme && !(url.scheme != "http" || url.scheme != "https"))

      url = url.to_s
      return :disable if disable_url?(url)
      return :download if download_url?(url)
    end

    private

    def download_url?(url)
      @patterns["blacklist"].each do |pattern|
        return false if url.match(pattern)
      end

      match = false
      @patterns["whitelist"].each do |pattern|
        match = true if url.match(pattern)
      end

      match
    end

    def disable_url?(url)
      @patterns["disable"].each do |pattern|
        return true if url.match(pattern)
      end

      false
    end
  end
end
