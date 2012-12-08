require "curb"

module CourseraDownloader
  class Course
    def initialize(name)
      @name = name

      @curl = Curl::Easy.new do |curl|
        curl.verbose = VERBOSE
        curl.enable_cookies = true
        curl.cookiefile = COOKIE_FILE
        curl.cookiejar = COOKIE_FILE
        curl.follow_location = true
      end

      @downloader = Downloader.new(@curl)
    end

    def login(email, password)
      @curl.url = login_redirect_url
      @curl.http_get

      @curl.url = @curl.last_effective_url

      @curl.http_post([
        Curl::PostField.content('email', email),
        Curl::PostField.content('password', password),
        Curl::PostField.content('login', "Login")
      ])
    end

    def host_url
      "https://class.coursera.org"
    end

    def index_url
      "#{host_url}/#{@name}/class/index"
    end

    def lecture_url
      "#{host_url}/#{@name}/lecture/index"
    end

    def get_index
      @downloader.get(index_url)
    end

    def get_lectures
      @downloader.get(lecture_url)
    end

    private

    def login_redirect_url
      "#{host_url}/#{@name}/auth/auth_redirector?type=login&subtype=normal&email=&visiting=&minimal=true"
    end

  end
end
