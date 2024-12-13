require "rails_helper"

RSpec.describe AuthMailer, type: :mailer do
  describe "#confirmation_email" do
    context "when new user" do
      let(:user) { build(:user, email: "test@example.com") }

      it "send confirmation mail" do
        described_class.confirmation_email(user).deliver_now
        mail =  ActionMailer::Base.deliveries.last
        expect(mail.to.first).to eq("test@example.com")
        expect(mail.subject).to eq("Please confirm your email address")
        expect(mail.html_part.body.raw_source).to match(%r{/auth/confirm\?token=})
        expect(mail.text_part.body.raw_source).to match(%r{/auth/confirm\?token=})
      end
    end

    context "when exists user" do
      let(:user) { build(:user, email: "test@example.com") }

      before do
        create(:user, email: "test@example.com", password: "password")
      end

      it "raises an error" do
        expect { described_class.confirmation_email(user).deliver_now }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when invalid email" do
      let(:user) { build(:user, email: nil) }

      it "raises an error" do
        expect { described_class.confirmation_email(user).deliver_now }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
