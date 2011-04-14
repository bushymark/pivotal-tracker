module PivotalTracker
  class Client

    class NoToken < StandardError; end

    class << self
      attr_writer :use_ssl, :token, :uri

      def use_ssl
        @use_ssl || false
      end

      def token(username, password, method='post')
        return @token if @token
        response = if method == 'post'
          RestClient.post "https://#{uri}/services/v3/tokens/active", :username => username, :password => password
        else
          RestClient.get "https://#{username}:#{password}@#{uri}/services/v3/tokens/active"
        end
        @token= Nokogiri::XML(response.body).search('guid').inner_html
      end

      # this is your connection for the entire module
      def connection(options={})
        raise NoToken if @token.to_s.empty?

        @connections ||= {}

        @connections[@token] ||= RestClient::Resource.new("#{protocol}://#{uri}/services/v3", :headers => {'X-TrackerToken' => @token, 'Content-Type' => 'application/xml'})
      end
      
      def uri
        @uri ||= "www.pivotaltracker.com"
      end
      
      protected

        def protocol
          use_ssl ? 'https' : 'http'
        end

    end

  end
end
