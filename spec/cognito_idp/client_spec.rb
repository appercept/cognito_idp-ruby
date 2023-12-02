# frozen_string_literal: true

require "faraday"
require "json"

RSpec.describe CognitoIdp::Client do
  subject(:client) { described_class.new(client_id: client_id, client_secret: client_secret, domain: domain, adapter: :test, stubs: stubs) }

  let(:client_id) { "client1" }
  let(:client_secret) { nil }
  let(:domain) { "auth.example.com" }
  let(:stubs) { nil }

  it "has a version number" do
    expect(CognitoIdp::VERSION).not_to be nil
  end

  describe "#authorization_uri" do
    subject(:uri) { client.authorization_uri(redirect_uri: redirect_uri) }

    let(:redirect_uri) { "https://www.example.com/auth/callback" }

    let(:decoded_uri) { URI.parse(uri) }
    let(:decoded_uri_params) { URI.decode_www_form(decoded_uri.query) }

    it { expect(decoded_uri.scheme).to eq("https") }
    it { expect(decoded_uri.host).to eq(domain) }
    it { expect(decoded_uri.path).to eq("/oauth2/authorize") }
    it { expect(decoded_uri_params.size).to eq(3) }
    it { expect(decoded_uri_params).to include(["client_id", client_id]) }
    it { expect(decoded_uri_params).to include(["redirect_uri", redirect_uri]) }
    it { expect(decoded_uri_params).to include(["response_type", "code"]) }

    context "when given additional valid options" do
      subject(:uri) { client.authorization_uri(redirect_uri: redirect_uri, scope: scope) }

      let(:scope) { "openid email" }

      it { expect(decoded_uri_params).to include(["scope", scope]) }
    end
  end

  describe "#get_token" do
    context "when exchanging an authorization code for tokens" do
      subject(:token) { client.get_token(grant_type: grant_type, code: code, redirect_uri: redirect_uri) }

      let(:grant_type) { "authorization_code" }
      let(:code) { "code1" }
      let(:redirect_uri) { "https://www.example.com/auth/callback" }
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post("https://auth.example.com/oauth2/token", params_matcher) do |env|
            [200, {"Content-Type" => "application/json"}, response_payload.to_json]
          end
        end
      end
      let(:params_matcher) do
        ->(request_body) do
          params = URI.decode_www_form(request_body)
          params.include?(["client_id", client_id]) &&
            params.include?(["code", code]) &&
            params.include?(["grant_type", grant_type]) &&
            params.include?(["redirect_uri", redirect_uri])
        end
      end
      let(:response_payload) do
        {
          access_token: access_token,
          id_token: id_token,
          token_type: token_type,
          expires_in: expires_in
        }
      end
      let(:access_token) { "eyJra1example" }
      let(:id_token) { "eyJra2example" }
      let(:token_type) { "Bearer" }
      let(:expires_in) { 7200 }

      it { expect(token.access_token).to eq(access_token) }
      it { expect(token.id_token).to eq(id_token) }
      it { expect(token.token_type).to eq(token_type) }
      it { expect(token.expires_in).to eq(expires_in) }

      context "when client_secret is not set" do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post("https://auth.example.com/oauth2/token") do |env|
              fail "Authorization is present.#{env.request_headers}" if env.request_headers.key?("Authorization")
            end
          end
        end

        it "does not add authorization" do
          client.get_token(grant_type: grant_type, code: code)
        end
      end

      context "when client_secret is set" do
        let(:client_secret) { "SECRET" }
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post("https://auth.example.com/oauth2/token") do |env|
              id_and_secret = "#{client_id}:#{client_secret}"
              basic_auth = "Basic #{Base64.urlsafe_encode64(id_and_secret)}"
              fail "Basic Authorization is missing." unless env.request_headers["Authorization"] == basic_auth
            end
          end
        end

        it "adds basic authorization" do
          client.get_token(grant_type: grant_type, code: code)
        end
      end

      context "when given a block it yields control on success" do
        it { expect { |b| client.get_token(grant_type: grant_type, code: code, redirect_uri: redirect_uri, &b) }.to yield_with_args(CognitoIdp::Token) }
      end

      context "when response is an error" do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post("https://auth.example.com/oauth2/token") do |env|
              [400, {"Content-Type" => "application/json"}, response_payload.to_json]
            end
          end
        end
        let(:response_payload) do
          {error: error}
        end
        let(:error) { "invalid_request" }

        it { is_expected.to be_nil }
      end
    end

    context "when exchanging client credentials for an access token" do
      subject(:token) { client.get_token(grant_type: grant_type, scope: scope) }

      let(:client_secret) { "SECRET" }
      let(:grant_type) { "client_credentials" }
      let(:scope) { "openid email" }
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post("https://auth.example.com/oauth2/token", params_matcher) do |env|
            id_and_secret = "#{client_id}:#{client_secret}"
            basic_auth = "Basic #{Base64.urlsafe_encode64(id_and_secret)}"
            fail "Basic Authorization is missing." unless env.request_headers["Authorization"] == basic_auth
            [200, {"Content-Type" => "application/json"}, response_payload.to_json]
          end
        end
      end
      let(:params_matcher) do
        ->(request_body) do
          params = URI.decode_www_form(request_body)
          params.include?(["client_id", client_id]) &&
            params.include?(["grant_type", grant_type]) &&
            params.include?(["scope", scope])
        end
      end
      let(:response_payload) do
        {
          access_token: access_token,
          id_token: id_token,
          token_type: token_type,
          expires_in: expires_in
        }
      end
      let(:access_token) { "eyJra1example" }
      let(:id_token) { "eyJra2example" }
      let(:token_type) { "Bearer" }
      let(:expires_in) { 7200 }

      it { expect(token.access_token).to eq(access_token) }
      it { expect(token.id_token).to eq(id_token) }
      it { expect(token.token_type).to eq(token_type) }
      it { expect(token.expires_in).to eq(expires_in) }

      context "when given a block it yields control on success" do
        it { expect { |b| client.get_token(grant_type: grant_type, scope: scope, &b) }.to yield_with_args(CognitoIdp::Token) }
      end

      context "when response is an error" do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post("https://auth.example.com/oauth2/token") do |env|
              [400, {"Content-Type" => "application/json"}, response_payload.to_json]
            end
          end
        end
        let(:response_payload) do
          {error: error}
        end
        let(:error) { "invalid_request" }

        it { is_expected.to be_nil }
      end
    end

    context "when exchanging an authorization code with PKCE for tokens" do
      subject(:token) { client.get_token(grant_type: grant_type, code: code, code_verifier: code_verifier, redirect_uri: redirect_uri) }

      let(:grant_type) { "authorization_code" }
      let(:code) { "code1" }
      let(:code_verifier) { "CODE_VERIFIER" }
      let(:redirect_uri) { "https://www.example.com/auth/callback" }
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post("https://auth.example.com/oauth2/token", params_matcher) do |env|
            [200, {"Content-Type" => "application/json"}, response_payload.to_json]
          end
        end
      end
      let(:params_matcher) do
        ->(request_body) do
          params = URI.decode_www_form(request_body)
          params.include?(["client_id", client_id]) &&
            params.include?(["code", code]) &&
            params.include?(["code_verifier", code_verifier]) &&
            params.include?(["grant_type", grant_type]) &&
            params.include?(["redirect_uri", redirect_uri])
        end
      end
      let(:response_payload) do
        {
          access_token: access_token,
          id_token: id_token,
          token_type: token_type,
          expires_in: expires_in
        }
      end
      let(:access_token) { "eyJra1example" }
      let(:id_token) { "eyJra2example" }
      let(:token_type) { "Bearer" }
      let(:expires_in) { 7200 }

      it { expect(token.access_token).to eq(access_token) }
      it { expect(token.id_token).to eq(id_token) }
      it { expect(token.token_type).to eq(token_type) }
      it { expect(token.expires_in).to eq(expires_in) }

      context "when client_secret is not set" do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post("https://auth.example.com/oauth2/token") do |env|
              fail "Authorization is present.#{env.request_headers}" if env.request_headers.key?("Authorization")
            end
          end
        end

        it "does not add authorization" do
          client.get_token(grant_type: grant_type, code: code)
        end
      end

      context "when client_secret is set" do
        let(:client_secret) { "SECRET" }
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post("https://auth.example.com/oauth2/token") do |env|
              id_and_secret = "#{client_id}:#{client_secret}"
              basic_auth = "Basic #{Base64.urlsafe_encode64(id_and_secret)}"
              fail "Basic Authorization is missing." unless env.request_headers["Authorization"] == basic_auth
            end
          end
        end

        it "adds basic authorization" do
          client.get_token(grant_type: grant_type, code: code)
        end
      end

      context "when given a block it yields control on success" do
        it { expect { |b| client.get_token(grant_type: grant_type, code: code, code_verifier: code_verifier, redirect_uri: redirect_uri, &b) }.to yield_with_args(CognitoIdp::Token) }
      end

      context "when response is an error" do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post("https://auth.example.com/oauth2/token") do |env|
              [400, {"Content-Type" => "application/json"}, response_payload.to_json]
            end
          end
        end
        let(:response_payload) do
          {error: error}
        end
        let(:error) { "invalid_request" }

        it { is_expected.to be_nil }
      end
    end

    context "when exchanging a refresh token for tokens" do
      subject(:token) { client.get_token(grant_type: grant_type, refresh_token: refresh_token) }

      let(:client_secret) { "SECRET" }
      let(:grant_type) { "refresh_token" }
      let(:refresh_token) { "eyJj3example" }
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post("https://auth.example.com/oauth2/token", params_matcher) do |env|
            id_and_secret = "#{client_id}:#{client_secret}"
            basic_auth = "Basic #{Base64.urlsafe_encode64(id_and_secret)}"
            fail "Basic Authorization is missing." unless env.request_headers["Authorization"] == basic_auth
            [200, {"Content-Type" => "application/json"}, response_payload.to_json]
          end
        end
      end
      let(:params_matcher) do
        ->(request_body) do
          params = URI.decode_www_form(request_body)
          params.include?(["client_id", client_id]) &&
            params.include?(["grant_type", grant_type]) &&
            params.include?(["refresh_token", refresh_token])
        end
      end
      let(:response_payload) do
        {
          access_token: access_token,
          id_token: id_token,
          token_type: token_type,
          expires_in: expires_in
        }
      end
      let(:access_token) { "eyJra1example" }
      let(:id_token) { "eyJra2example" }
      let(:token_type) { "Bearer" }
      let(:expires_in) { 7200 }

      it { expect(token.access_token).to eq(access_token) }
      it { expect(token.id_token).to eq(id_token) }
      it { expect(token.token_type).to eq(token_type) }
      it { expect(token.expires_in).to eq(expires_in) }

      context "when given a block it yields control on success" do
        it { expect { |b| client.get_token(grant_type: grant_type, refresh_token: refresh_token, &b) }.to yield_with_args(CognitoIdp::Token) }
      end

      context "when response is an error" do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            stub.post("https://auth.example.com/oauth2/token") do |env|
              [400, {"Content-Type" => "application/json"}, response_payload.to_json]
            end
          end
        end
        let(:response_payload) do
          {error: error}
        end
        let(:error) { "invalid_request" }

        it { is_expected.to be_nil }
      end
    end
  end

  describe "#get_user_info" do
    subject(:user_info) { client.get_user_info(token) }

    let(:token) { fail "must let a token" }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post("https://auth.example.com/oauth2/userInfo", nil, {"Authorization" => "Bearer #{access_token}"}) do |env|
          [200, {"Content-Type" => "application/json"}, response_payload.to_json]
        end
      end
    end
    let(:access_token) { fail "must let an access_token" }
    let(:response_payload) do
      {
        sub: sub,
        name: name,
        given_name: given_name,
        family_name: family_name,
        preferred_username: preferred_username,
        email: email,
        phone_number: phone_number,
        email_verified: email_verified,
        phone_number_verified: phone_number_verified
      }
    end
    let(:sub) { "248289761001" }
    let(:name) { "Jane Doe" }
    let(:given_name) { "Jane" }
    let(:family_name) { "Doe" }
    let(:preferred_username) { "j.doe" }
    let(:email) { "janedoe@example.com" }
    let(:phone_number) { "+12065551212" }
    let(:email_verified) { "true" }
    let(:phone_number_verified) { "true" }

    context "when token is a String" do
      let(:token) { "ACCESS_TOKEN" }
      let(:access_token) { token }

      it { is_expected.to be_a(CognitoIdp::UserInfo) }
      it { expect(user_info.sub).to eq(sub) }
      it { expect(user_info.name).to eq(name) }
      it { expect(user_info.given_name).to eq(given_name) }
      it { expect(user_info.family_name).to eq(family_name) }
      it { expect(user_info.preferred_username).to eq(preferred_username) }
      it { expect(user_info.email).to eq(email) }
      it { expect(user_info.phone_number).to eq(phone_number) }
      it { expect(user_info.email_verified).to eq(email_verified) }
      it { expect(user_info.phone_number_verified).to eq(phone_number_verified) }
    end

    context "when token is a Token" do
      let(:token) do
        CognitoIdp::Token.new(
          access_token: access_token,
          id_token: id_token,
          token_type: token_type,
          expires_in: expires_in
        )
      end
      let(:access_token) { "eyJra1example" }
      let(:id_token) { "eyJra2example" }
      let(:token_type) { "Bearer" }
      let(:expires_in) { 7200 }

      it { is_expected.to be_a(CognitoIdp::UserInfo) }
      it { expect(user_info.sub).to eq(sub) }
      it { expect(user_info.name).to eq(name) }
      it { expect(user_info.given_name).to eq(given_name) }
      it { expect(user_info.family_name).to eq(family_name) }
      it { expect(user_info.preferred_username).to eq(preferred_username) }
      it { expect(user_info.email).to eq(email) }
      it { expect(user_info.phone_number).to eq(phone_number) }
      it { expect(user_info.email_verified).to eq(email_verified) }
      it { expect(user_info.phone_number_verified).to eq(phone_number_verified) }
    end

    context "when given a block it yields control on success" do
      let(:token) { "ACCESS_TOKEN" }
      let(:access_token) { token }

      it { expect { |b| client.get_user_info(access_token, &b) }.to yield_with_args(CognitoIdp::UserInfo) }
    end

    context "when response is an error" do
      let(:token) { "ACCESS_TOKEN" }
      let(:access_token) { token }
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post("https://auth.example.com/oauth2/userInfo") do |env|
            [400, {"Content-Type" => "application/json"}, response_payload.to_json]
          end
        end
      end
      let(:response_payload) do
        {error: error}
      end
      let(:error) { "invalid_request" }

      it { is_expected.to be_nil }
    end
  end

  describe "#logout_uri" do
    subject(:uri) { client.logout_uri }

    let(:decoded_uri) { URI.parse(uri) }
    let(:decoded_uri_params) { URI.decode_www_form(decoded_uri.query) }

    it { expect(decoded_uri.scheme).to eq("https") }
    it { expect(decoded_uri.host).to eq(domain) }
    it { expect(decoded_uri.path).to eq("/logout") }
    it { expect(decoded_uri_params.size).to eq(1) }
    it { expect(decoded_uri_params).to include(["client_id", client_id]) }

    context "when given additional valid options" do
      subject(:uri) { client.authorization_uri(redirect_uri: redirect_uri, state: state) }

      let(:redirect_uri) { "https://www.example.com/auth/callback" }
      let(:state) { "STATE" }

      it { expect(decoded_uri_params).to include(["redirect_uri", redirect_uri]) }
      it { expect(decoded_uri_params).to include(["state", state]) }
    end
  end
end
