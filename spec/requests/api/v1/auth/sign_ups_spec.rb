require 'rails_helper'

RSpec.describe "Api::V1::Auth::SignUps", type: :request do
  include Mail::Matchers

  describe "POST /api/v1/auth/sign_up" do
    context "when valid params" do
      let(:params) do
        {
          user: { email: "test@example.com" }
        }
      end

      it "send confirmation mail" do
        expect { post api_v1_auth_sign_up_path params: params }
          .to change(ActionMailer::Base.deliveries, :size)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Confirmation email sent. Please check your inbox.")
      end
    end

    context "when invalid params" do
      let(:params) do
        {
          email: "test@example.example"
        }
      end

      it "return error response" do
        post api_v1_auth_sign_up_path params: params
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include("param is missing")
      end
    end

    context "when invalid email" do
      let(:params) do
        {
          user: { email: "aaaaa" }
        }
      end

      it "return error response" do
        post api_v1_auth_sign_up_path params: params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email")
      end
    end
  end
end
