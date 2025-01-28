# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Auth::SignUp::Callbacks", type: :request do
  describe "GET /api/v1/auth/sign_up/:token/callback" do
    context "token does exists" do
      let(:user) { User.new(email: "test@example.com") }
      let(:token) { user.generate_confirmation_token }

      it "returns message" do
        get api_v1_auth_sign_up_callback_path(token)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Confirmation token")
      end
    end

    context "token does not exists" do
      let(:token) { SecureRandom.urlsafe_base64 }

      it "returns error" do
        get api_v1_auth_sign_up_callback_path(token)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/auth/sign_up/:token/callback" do
    context "token does exists" do
      let(:user) { User.new(email: "test@example.com") }
      let(:token) { user.generate_confirmation_token }
      let(:params) { { user: {  password: "password", password_confirmation: "password" } } }

      it "create a new User" do
        expect { post api_v1_auth_sign_up_callback_path(token), params: params }.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.body).to include("Create User")
      end
    end

    context "token does not exists" do
      let(:token) { SecureRandom.urlsafe_base64 }
      let(:params) { { user: {  password: "password", password_confirmation: "password" } } }

      it "not create User" do
        expect { post api_v1_auth_sign_up_callback_path(token), params: params }.not_to(change(User, :count))
        expect(response).to have_http_status(:not_found)
      end
    end

    context "password_confirmation differs from password" do
      let(:user) { User.new(email: "test@example.com") }
      let(:token) { user.generate_confirmation_token }
      let(:params) { { user: {  password: "password", password_confirmation: "password1" } } }

      it "returns error" do
        expect { post api_v1_auth_sign_up_callback_path(token), params: params }.not_to(change(User, :count))
        expect(response).to have_http_status(:unprocessable_entity)
        data = JSON.parse(response.body)
        expect(data["errors"]["password_confirmation"]).to eq([ "doesn't match Password" ])
      end
    end
  end
end
