# frozen_string_literal: true

RSpec.describe CognitoIdp::LogoutUri do
  subject(:uri) do
    described_class.new(client_id: client_id, domain: domain)
  end

  let(:client_id) { "client-id-1" }
  let(:domain) { "id.example.com" }

  it { expect(uri.client_id).to eq(client_id) }
  it { expect(uri.domain).to eq(domain) }
  it { expect(uri.logout_uri).to be_nil }
  it { expect(uri.redirect_uri).to be_nil }
  it { expect(uri.response_type).to be_nil }
  it { expect(uri.scope).to be_nil }
  it { expect(uri.state).to be_nil }

  context "when logout_uri is set" do
    subject(:uri) do
      described_class.new(logout_uri: logout_uri, client_id: client_id, domain: domain)
    end

    let(:logout_uri) { "https://www.example.com/auth/callback" }

    it { expect(uri.logout_uri).to eq(logout_uri) }
  end

  context "when redirect_uri is set" do
    subject(:uri) do
      described_class.new(redirect_uri: redirect_uri, client_id: client_id, domain: domain)
    end

    let(:redirect_uri) { "https://www.example.com/auth/callback" }

    it { expect(uri.redirect_uri).to eq(redirect_uri) }
  end

  context "when response_type is set" do
    subject(:uri) do
      described_class.new(response_type: response_type, client_id: client_id, domain: domain)
    end

    let(:response_type) { :code }

    it { expect(uri.response_type).to eq(response_type) }
  end

  context "when scope is set" do
    subject(:uri) do
      described_class.new(scope: scope, client_id: client_id, domain: domain)
    end

    let(:scope) { "openid" }

    it { expect(uri.scope).to eq(scope) }
  end

  context "when state is set" do
    subject(:uri) do
      described_class.new(state: state, client_id: client_id, domain: domain)
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
    it { expect(decoded_uri.path).to eq("/logout") }
    it { expect(decoded_uri_params.size).to eq(1) }
    it { expect(decoded_uri_params).to include(["client_id", client_id]) }

    context "when logout_uri is set" do
      let(:uri) do
        described_class.new(logout_uri: logout_uri, client_id: client_id, domain: domain)
      end

      let(:logout_uri) { "https://www.example.com/auth/callback" }

      it { expect(decoded_uri_params).to include(["logout_uri", logout_uri]) }
    end

    context "when redirect_uri is set" do
      let(:uri) do
        described_class.new(redirect_uri: redirect_uri, client_id: client_id, domain: domain)
      end

      let(:redirect_uri) { "https://www.example.com/auth/callback" }

      it { expect(decoded_uri_params).to include(["redirect_uri", redirect_uri]) }
    end

    context "when response_type is set" do
      let(:uri) do
        described_class.new(response_type: response_type, client_id: client_id, domain: domain)
      end

      let(:response_type) { "token" }

      it { expect(decoded_uri_params).to include(["response_type", response_type]) }
    end

    context "when scope is set as an Array" do
      let(:uri) do
        described_class.new(scope: scope, client_id: client_id, domain: domain)
      end

      let(:scope) { ["openid", "email", "profile"] }

      it { expect(decoded_uri_params).to include(["scope", "openid email profile"]) }
    end

    context "when scope is set as a String" do
      let(:uri) do
        described_class.new(scope: scope, client_id: client_id, domain: domain)
      end

      let(:scope) { "openid email" }

      it { expect(decoded_uri_params).to include(["scope", scope]) }
    end

    context "when state is set" do
      let(:uri) do
        described_class.new(state: state, client_id: client_id, domain: domain)
      end

      let(:state) { "STATE" }

      it { expect(decoded_uri_params).to include(["state", state]) }
    end
  end
end
