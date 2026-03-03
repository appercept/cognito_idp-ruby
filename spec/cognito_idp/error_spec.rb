# frozen_string_literal: true

RSpec.describe CognitoIdp::Error do
  it "inherits from StandardError" do
    expect(described_class).to be < StandardError
  end

  describe "#message" do
    context "when only error is provided" do
      subject(:error) { described_class.new(error: "invalid_request") }

      it { expect(error.message).to eq("invalid_request") }
    end

    context "when error and error_description are provided" do
      subject(:error) { described_class.new(error: "invalid_grant", error_description: "Authorization code has expired") }

      it { expect(error.message).to eq("invalid_grant: Authorization code has expired") }
    end
  end

  describe "attribute readers" do
    subject(:error) { described_class.new(error: "invalid_grant", error_description: "Authorization code has expired", http_status: 400) }

    it { expect(error.error).to eq("invalid_grant") }
    it { expect(error.error_description).to eq("Authorization code has expired") }
    it { expect(error.http_status).to eq(400) }
  end
end
