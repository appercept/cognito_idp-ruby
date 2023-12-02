# frozen_string_literal: true

module CognitoIdp
  class LogoutUri
    attr_accessor :client_id, :domain, :logout_uri, :redirect_uri, :response_type, :scope, :state

    def initialize(client_id:, domain:, **options)
      @client_id = client_id
      @domain = domain
      @logout_uri = options[:logout_uri]
      @redirect_uri = options[:redirect_uri]
      @response_type = options[:response_type]
      @scope = options[:scope]
      @state = options[:state]
    end

    def to_s
      URI("https://#{domain}/logout").tap do |uri|
        uri.query = URI.encode_www_form(params)
      end.to_s
    end

    private

    def params
      {
        client_id: client_id,
        logout_uri: logout_uri,
        redirect_uri: redirect_uri,
        response_type: response_type,
        scope: scope_string,
        state: state
      }.compact
    end

    def scope_string
      return nil if scope.nil?

      Array(scope).join(" ")
    end
  end
end
