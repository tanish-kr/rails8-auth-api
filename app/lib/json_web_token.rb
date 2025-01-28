# frozen_string_literal: true

class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base.to_s

  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end

    def decode(token)
      body = JWT.decode(token, SECRET_KEY).first
      HashWithIndifferentAccess.new(body)
    rescue JWT::DecodeError => e
      Rails.logger.warn(e)
      nil
    end
  end
end
