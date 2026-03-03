# frozen_string_literal: true

require "timecop"

RSpec.describe CognitoIdp::Token do
  subject(:token) { described_class.new(token_hash) }

  let(:token_hash) do
    {}
  end

  it { expect(token.access_token).to be_nil }
  it { expect(token.id_token).to be_nil }
  it { expect(token.token_type).to be_nil }
  it { expect(token.expires_in).to be_nil }
  it { expect(token.expires_at).to be_nil }
  it { expect(token.refresh_token).to be_nil }

  describe "#expired?" do
    context "when expires_in is nil" do
      it { expect(token.expired?).to be false }
    end

    context "when token has not expired" do
      let(:token_hash) { {"expires_in" => 3600} }

      it { expect(token.expired?).to be false }
    end

    context "when token has expired" do
      let(:token_hash) { {"expires_in" => 3600} }

      before do
        Timecop.freeze
        token # force creation at frozen time
        Timecop.freeze(Time.now + 3601)
      end

      after { Timecop.return }

      it { expect(token.expired?).to be true }
    end

    context "when token is at the exact expiry time" do
      let(:token_hash) { {"expires_in" => 3600} }

      before do
        Timecop.freeze
        token # force creation at frozen time
        Timecop.freeze(Time.now + 3600)
      end

      after { Timecop.return }

      it { expect(token.expired?).to be true }
    end
  end

  describe "#inspect" do
    context "when token values are set" do
      let(:token_hash) do
        {
          "access_token" => "secret-access",
          "id_token" => "secret-id",
          "token_type" => "Bearer",
          "expires_in" => 3600,
          "refresh_token" => "secret-refresh"
        }
      end

      it "redacts access_token" do
        expect(token.inspect).to include("@access_token=[REDACTED]")
        expect(token.inspect).not_to include("secret-access")
      end

      it "redacts id_token" do
        expect(token.inspect).to include("@id_token=[REDACTED]")
        expect(token.inspect).not_to include("secret-id")
      end

      it "redacts refresh_token" do
        expect(token.inspect).to include("@refresh_token=[REDACTED]")
        expect(token.inspect).not_to include("secret-refresh")
      end

      it "shows non-secret attributes" do
        expect(token.inspect).to include('@token_type="Bearer"')
        expect(token.inspect).to include("@expires_in=3600")
      end
    end

    context "when token values are nil" do
      it "shows nil for absent tokens" do
        expect(token.inspect).to include("@access_token=nil")
        expect(token.inspect).to include("@id_token=nil")
        expect(token.inspect).to include("@refresh_token=nil")
      end
    end
  end

  context "when token is initialized with values" do
    let(:token_hash) do
      {
        "access_token" => "eyJra1example",
        "id_token" => "eyJra2example",
        "token_type" => "Bearer",
        "expires_in" => 3600,
        "refresh_token" => "refresh-token-1"
      }
    end

    before do
      Timecop.freeze
    end

    after do
      Timecop.return
    end

    it { expect(token.access_token).to eq("eyJra1example") }
    it { expect(token.id_token).to eq("eyJra2example") }
    it { expect(token.token_type).to eq("Bearer") }
    it { expect(token.expires_in).to eq(3600) }
    it { expect(token.expires_at).to eq(Time.now + 3600) }
    it { expect(token.refresh_token).to eq("refresh-token-1") }
  end
end
