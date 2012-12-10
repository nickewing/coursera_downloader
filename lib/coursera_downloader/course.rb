require "curb"
require "tempfile"

module CourseraDownloader
  class Course
    attr_reader :cookie_file

    def initialize(name)
      @name = name
      @cookie_file = Tempfile.new('coursera_cookies')
    end

    def login(email, password)
      curl = Curl::Easy.new

      curl.verbose = false
      curl.enable_cookies = true
      curl.cookiefile = @cookie_file.path
      curl.cookiejar = @cookie_file.path
      curl.follow_location = true

      curl.url = login_redirect_url
      curl.http_get

      curl.url = curl.last_effective_url
      curl.http_post([
        Curl::PostField.content('email', email),
        Curl::PostField.content('password', password),
        Curl::PostField.content('login', "Login")
      ])

      curl.follow_location = false
      curl.url = index_url
      curl.http_get

      response_code = curl.response_code
      curl.close

      response_code == 200
    end

    def host_url
      "https://class.coursera.org"
    end

    def index_url
      "#{host_url}/#{@name}/class/index"
    end

    private

    def login_redirect_url
      "#{host_url}/#{@name}/auth/auth_redirector?type=login&subtype=normal&email=&visiting=&minimal=true"
    end

  end
end
