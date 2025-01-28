# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Auth::SignOuts", type: :request do
  describe "DELETE /api/v1/auth/sign_out" do
    let!(:user) { create(:user, email: "test@example.com", password: "password") }
    let!(:session) { create(:session, user: user) }
    let(:token) { JsonWebToken.encode({ user_id: session.user_id, session_id: session.id }, 15.minutes.from_now) }
    let(:headers) do
      {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Authorization' => token
      }
    end

    it "session does deleted" do
      expect { delete api_v1_auth_sign_out_path, headers: headers }.to change { Session.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
