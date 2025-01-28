# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern
  class AuthenticationError < StandardError; end

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

    def authenticated?
      Current.user.present?
    end

    def require_authentication
      raise AuthenticationError, "Unauthorized User" unless authenticate_user
    end

    def authenticate_user
      token = request.headers["Authorization"]&.split(" ")&.last
      payload = JsonWebToken.decode(token)
      session = find_session(payload)
      Current.session = session if session
    end

    def find_session(payload)
      return unless payload

      Session.find_by(id: payload[:session_id], user_id: payload[:user_id])
    end

    def generate_access_token(session)
      payload = { user_id: session.user_id, session_id: session.id }
      JsonWebToken.encode(payload, 15.minutes.from_now)
    end

    def generate_refresh_token(session)
      payload = { user_id: session.user_id, session_id: session.id }
      JsonWebToken.encode(payload, 1.month.from_now)
    end

    def refresh_access_token(refresh_token)
      payload = JsonWebToken.decode(refresh_token)
      session = find_session(payload)
      generate_access_token(session) if session
    end

    def start_new_session_for(user)
      session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
      Current.session = session
      access_token = generate_access_token(session)
      refresh_token = generate_refresh_token(session)
      [ access_token, refresh_token ]
    end

    def terminate_session
      Current.session&.destroy
    end
end
