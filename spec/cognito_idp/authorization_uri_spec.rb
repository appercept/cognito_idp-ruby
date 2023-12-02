# frozen_string_literal: true

RSpec.describe CognitoIdp::AuthorizationUri do
  subject(:uri) do
    described_class.new(client_id: client_id, domain: domain, redirect_uri: redirect_uri)
  end

  let(:client_id) { "client-id-1" }
  let(:domain) { "id.example.com" }
  let(:redirect_uri) { "https://example.com/auth/callback" }

  it { expect(uri.client_id).to eq(client_id) }
  it { expect(uri.code_challenge_method).to be_nil }
  it { expect(uri.code_challenge).to be_nil }
  it { expect(uri.domain).to eq(domain) }
  it { expect(uri.identity_provider).to be_nil }
  it { expect(uri.idp_identifier).to be_nil }
  it { expect(uri.nonce).to be_nil }
  it { expect(uri.redirect_uri).to eq(redirect_uri) }
  it { expect(uri.response_type).to eq(:code) }
  it { expect(uri.scope).to be_nil }
  it { expect(uri.state).to be_nil }

  context "when code_challenge_method is set" do
    subject(:uri) do
      described_class.new(code_challenge_method: code_challenge_method, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
    end

    let(:code_challenge_method) { "S256" }

    it { expect(uri.code_challenge_method).to eq(code_challenge_method) }
  end

  context "when code_challenge is set" do
    subject(:uri) do
      described_class.new(code_challenge: code_challenge, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
    end

    let(:code_challenge) { "CHALLENGE" }

    it { expect(uri.code_challenge).to eq(code_challenge) }
  end

  context "when identity_provider is set" do
    subject(:uri) do
      described_class.new(identity_provider: identity_provider, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
    end

    let(:identity_provider) { "LoginWithAmazon" }

    it { expect(uri.identity_provider).to eq(identity_provider) }
  end

  context "when idp_identifier is set" do
    subject(:uri) do
      described_class.new(idp_identifier: idp_identifier, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
    end

    let(:idp_identifier) { "MyIdP" }

    it { expect(uri.idp_identifier).to eq(idp_identifier) }
  end

  context "when nonce is set" do
    subject(:uri) do
      described_class.new(nonce: nonce, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
    end

    let(:nonce) { "RANDOM" }

    it { expect(uri.nonce).to eq(nonce) }
  end

  context "when scope is set" do
    subject(:uri) do
      described_class.new(scope: scope, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
    end

    let(:scope) { "openid" }

    it { expect(uri.scope).to eq(scope) }
  end

  context "when state is set" do
    subject(:uri) do
      described_class.new(state: state, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
    end

    let(:state) { "STATE" }

    it { expect(uri.state).to eq(state) }
  end

  describe "#to_s" do
    subject(:string_value) { uri.to_s }

    let(:decoded_uri) { URI.parse(string_value) }
    let(:decoded_uri_params) { URI.decode_www_form(decoded_uri.query) }

    it { expect(decoded_uri.scheme).to eq("https") }
    it { expect(decoded_uri.host).to eq(domain) }
    it { expect(decoded_uri.path).to eq("/oauth2/authorize") }
    it { expect(decoded_uri_params.size).to eq(3) }
    it { expect(decoded_uri_params).to include(["client_id", client_id]) }
    it { expect(decoded_uri_params).to include(["redirect_uri", redirect_uri]) }
    it { expect(decoded_uri_params).to include(["response_type", "code"]) }

    context "when code_challenge_method is set" do
      let(:uri) do
        described_class.new(code_challenge_method: code_challenge_method, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
      end

      let(:code_challenge_method) { "S256" }

      it { expect(decoded_uri_params).to include(["code_challenge_method", code_challenge_method]) }
    end

    context "when code_challenge is set" do
      let(:uri) do
        described_class.new(code_challenge: code_challenge, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
      end

      let(:code_challenge) { "CHALLENGE" }

      it { expect(decoded_uri_params).to include(["code_challenge", code_challenge]) }
    end

    context "when identity_provider is set" do
      let(:uri) do
        described_class.new(identity_provider: identity_provider, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
      end

      let(:identity_provider) { "LoginWithAmazon" }

      it { expect(decoded_uri_params).to include(["identity_provider", identity_provider]) }
    end

    context "when idp_identifier is set" do
      let(:uri) do
        described_class.new(idp_identifier: idp_identifier, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
      end

      let(:idp_identifier) { "MyIdP" }

      it { expect(decoded_uri_params).to include(["idp_identifier", idp_identifier]) }
    end

    context "when nonce is set" do
      let(:uri) do
        described_class.new(nonce: nonce, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
      end

      let(:nonce) { "RANDOM" }

      it { expect(decoded_uri_params).to include(["nonce", nonce]) }
    end

    context "when scope is set as an Array" do
      let(:uri) do
        described_class.new(scope: scope, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
      end

      let(:scope) { ["openid", "email", "profile"] }

      it { expect(decoded_uri_params).to include(["scope", "openid email profile"]) }
    end

    context "when scope is set as a String" do
      let(:uri) do
        described_class.new(scope: scope, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
      end

      let(:scope) { "openid email" }

      it { expect(decoded_uri_params).to include(["scope", scope]) }
    end

    context "when state is set" do
      let(:uri) do
        described_class.new(state: state, client_id: client_id, domain: domain, redirect_uri: redirect_uri)
      end

      let(:state) { "STATE" }

      it { expect(decoded_uri_params).to include(["state", state]) }
    end
  end
end
