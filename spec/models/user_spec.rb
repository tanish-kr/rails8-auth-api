require 'rails_helper'

RSpec.describe User, type: :model do
  include_context 'cache use to memory store'

  describe "::validates" do
    subject { user.valid? }

    describe ":email" do
      context "when email is invalid" do
        let(:user) { described_class.new(email: "test@example.com", password: "password") }

        it { is_expected.to be_truthy }
      end

      context "when email is empty" do
        let(:user) { described_class.new(email: nil, password: "password") }

        it { is_expected.to be_falsey }
      end

      context "when email is non domain" do
        let(:user) { described_class.new(email: "aaaa", password: "password") }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe "#generate_confirmation_token" do
    subject(:key) { user.generate_confirmation_token }
    context "when email is empty" do
      let(:user) { described_class.new(email: nil) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end

    context "when email is invalid" do
      let(:user) { described_class.new(email: "test@example.com", password: "password") }

      it { is_expected.not_to be_nil }

      it "token is saved in cache" do
        expect(key).not_to be_nil
        expect(Rails.cache.read(key)).not_to be_nil
      end
    end
  end

  describe "#read_confirmation_token" do
    let(:user) { described_class.new(email: "test@example.com", password: "password") }

    context "when token not found" do
      let(:key) { "notfound" }

      it "raises RecordNotFound error" do
        expect { user.read_confirmation_token(key) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when payload is empty" do
      let(:key) { "empty" }

      before do
        Rails.cache.write(key, "payload")
      end

      it "raises RecordNotFound error" do
        expect { user.read_confirmation_token(key) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when expired out to payload" do
      let(:key) { travel_to(25.hours.ago) { user.generate_confirmation_token } }

      it "raises RecordNotFound error" do
        expect { user.read_confirmation_token(key) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when valid payload" do
      let(:key) { user.generate_confirmation_token }

      it "return payload" do
        payload = user.read_confirmation_token(key)
        expect(payload).not_to be_nil
        expect(payload[:email]).to eq("test@example.com")
      end
    end
  end
end
