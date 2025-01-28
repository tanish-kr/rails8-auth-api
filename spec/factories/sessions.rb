# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    user
    ip_address {  '127.0.0.1' }
    user_agent { 'Mozilla/5.0 (Macintosh; Intel Mac OS' }
  end
end
