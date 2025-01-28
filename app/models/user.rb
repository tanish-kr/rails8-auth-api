# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true,
                    uniqueness: { case_insensitive: true }

  class << self
    def read_confirmation_token(key)
      token = Rails.cache.read(key)
      raise ActiveRecord::RecordNotFound.new("Token cannot be read.", self) if token.blank?

      Rails.cache.delete(key)
      payload = JsonWebToken.decode(token)

      raise ActiveRecord::RecordNotFound.new("Payload cannot be read.", self) if payload.blank?

      payload
    end
  end

  def generate_confirmation_token
    validate

    raise ActiveRecord::RecordInvalid, self if errors[:email].present?

    expire = 24.hours.from_now
    token = JsonWebToken.encode({ email: }, expire)
    key = SecureRandom.urlsafe_base64
    Rails.cache.write(key, token, expires_at: expire)
    key
  end
end
