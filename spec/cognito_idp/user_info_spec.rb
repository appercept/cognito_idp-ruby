# frozen_string_literal: true

RSpec.describe CognitoIdp::UserInfo do
  subject(:user_info) { described_class.new(user_info_hash) }

  let(:user_info_hash) do
    {}
  end

  it { expect(user_info.sub).to be_nil }
  it { expect(user_info.name).to be_nil }
  it { expect(user_info.given_name).to be_nil }
  it { expect(user_info.family_name).to be_nil }
  it { expect(user_info.preferred_username).to be_nil }
  it { expect(user_info.email).to be_nil }
  it { expect(user_info.phone_number).to be_nil }
  it { expect(user_info.email_verified).to be_nil }
  it { expect(user_info.phone_number_verified).to be_nil }

  context "when given attributes" do
    let(:user_info_hash) do
      {
        "sub" => sub,
        "name" => name,
        "given_name" => given_name,
        "family_name" => family_name,
        "preferred_username" => preferred_username,
        "email" => email,
        "phone_number" => phone_number,
        "email_verified" => email_verified,
        "phone_number_verified" => phone_number_verified
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
end
