require 'hello_sign/proxy'

require 'faraday'
require 'faraday_middleware-multi_json'

module HelloSign
  class Client
    include HelloSign::Proxy

    API_ENDPOINT = 'https://api.hellosign.com'
    API_VERSION  = '/v3'

    attr_reader :email_address, :password

    def initialize(email_address_or_hash, password = nil)
      if email_address_or_hash.is_a? Hash
        @email_address = email_address_or_hash.fetch(:email_address) { raise ArgumentError }
        @password      = email_address_or_hash.fetch(:password) { raise ArgumentError }
      else
        @email_address = email_address_or_hash
        @password      = password
      end
    end

    def get(path, options = {})
      request(:get, path, options)
    end

    def post(path, options = {})
      request(:post, path, options)
    end

    private

    def request(method, path, options)
      base_connection do |connection|
        connection.request :basic_auth, email_address, password unless options[:auth_not_required]
      end.send(method) do |request|
        request.url  "#{API_VERSION}#{path}", options[:params]
        request.body = options[:body]
      end.body
    end

    def base_connection
      Faraday.new(:url => API_ENDPOINT) do |connection|
        yield connection

        connection.request  :multipart
        connection.request  :url_encoded
        connection.response :multi_json, :symbolize_keys => true
        connection.adapter  :net_http
      end
    end

  end
end
