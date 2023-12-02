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

  context "when token is initialized with values" do
    let(:token_hash) do
      {
        "access_token" => "eyJra1example",
        "id_token" => "eyJra2example",
        "token_type" => "Bearer",
        "expires_in" => 3600
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
  end
end
