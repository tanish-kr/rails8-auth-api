# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Auth::SignIns", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    let(:params) do
      {
        user: {
          email:,
          password:
        }
      }
    end

    context "correct email and password" do
      let!(:user) { create(:user, email:, password:) }
      let(:password) { "password" }
      let(:email) { "user@example.com" }

      it "successfully sign in" do
        post api_v1_auth_sign_in_path, params: params
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data["access_token"]).not_to be_nil
        expect(data["refresh_token"]).not_to be_nil
        expect(data["access_token"]).not_to eq(data["refresh_token"])
      end
    end

    context "email does not exists" do
      let!(:user) { create(:user, email: "user@example.com", password:) }
      let(:password) { "password" }
      let(:email) { "user2@example.com" }

      it "unauthorized error" do
        post api_v1_auth_sign_in_path, params: params
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include("Unauthorized user.")
      end
    end

    context "password does not match" do
      let!(:user) { create(:user, email:, password: "password") }
      let(:password) { "passwordpassword" }
      let(:email) { "user@example.com" }

      it "unauthorized error" do
        post api_v1_auth_sign_in_path, params: params
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include("Unauthorized user.")
      end
    end
  end
end
