# frozen_string_literal: true

require "faraday"

module CognitoIdp
  class Client
    attr_accessor :adapter, :client_id, :client_secret, :domain

    def initialize(client_id:, domain:, client_secret: nil, adapter: Faraday.default_adapter, stubs: nil)
      @adapter = adapter
      @client_id = client_id
      @client_secret = client_secret
      @domain = domain
      @stubs = stubs
    end

    def authorization_uri(redirect_uri:, **options)
      AuthorizationUri.new(
        client_id: client_id,
        domain: domain,
        redirect_uri: redirect_uri,
        **options
      ).to_s
    end

    def get_token(grant_type:, **options)
      params = {
        client_id: client_id,
        code: options[:code],
        code_verifier: options[:code_verifier],
        grant_type: grant_type,
        redirect_uri: options[:redirect_uri],
        refresh_token: options[:refresh_token],
        scope: options[:scope]
      }.compact
      response = connection.post("/oauth2/token", params, basic_authorization_headers)
      return unless response.success?

      token = Token.new(response.body)
      yield(token) if block_given?
      token
    end

    def get_user_info(token)
      access_token = case token
      when Token
        token.access_token
      else
        token
      end
      response = connection.post("/oauth2/userInfo", nil, {"Authorization" => "Bearer #{access_token}"})
      return unless response.success?

      user_info = UserInfo.new(response.body)
      yield(user_info) if block_given?
      user_info
    end

    def logout_uri(**options)
      LogoutUri.new(
        client_id: client_id,
        domain: domain,
        **options
      ).to_s
    end

    private

    def connection
      @connection ||= Faraday.new do |conn|
        conn.url_prefix = "https://#{domain}"
        conn.request :url_encoded
        conn.response :json, content_type: "application/json"
        conn.adapter adapter, @stubs
      end
    end

    def basic_authorization_headers
      return if client_secret.nil?

      client_id_and_secret = "#{client_id}:#{client_secret}"
      {"Authorization" => "Basic #{Base64.urlsafe_encode64(client_id_and_secret)}"}
    end
  end
end
