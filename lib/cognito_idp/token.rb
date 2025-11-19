# frozen_string_literal: true

module CognitoIdp
  class Token
    attr_reader :access_token, :id_token, :token_type, :expires_at, :expires_in, :refresh_token

    def initialize(token_hash)
      token_hash.transform_keys(&:to_sym).tap do |values|
        @access_token = values[:access_token]
        @id_token = values[:id_token]
        @token_type = values[:token_type]
        @expires_in = values[:expires_in]
        @refresh_token = values[:refresh_token]
      end
      @expires_at = Time.now + expires_in unless expires_in.nil?
    end
  end
end
