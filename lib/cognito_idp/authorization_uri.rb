# frozen_string_literal: true

module CognitoIdp
  class AuthorizationUri
    attr_accessor :client_id, :code_challenge_method, :code_challenge, :domain,
      :idp_identifier, :identity_provider, :nonce, :redirect_uri, :response_type,
      :scope, :state

    def initialize(client_id:, domain:, redirect_uri:, response_type: :code, **options)
      @code_challenge_method = options[:code_challenge_method]
      @code_challenge = options[:code_challenge]
      @client_id = client_id
      @domain = domain
      @identity_provider = options[:identity_provider]
      @idp_identifier = options[:idp_identifier]
      @nonce = options[:nonce]
      @redirect_uri = redirect_uri
      @response_type = response_type
      @scope = options[:scope]
      @state = options[:state]
    end

    def to_s
      URI("https://#{domain}/oauth2/authorize").tap do |uri|
        uri.query = URI.encode_www_form(params)
      end.to_s
    end

    private

    def params
      {
        client_id: client_id,
        code_challenge_method: code_challenge_method,
        code_challenge: code_challenge,
        identity_provider: identity_provider,
        idp_identifier: idp_identifier,
        nonce: nonce,
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
