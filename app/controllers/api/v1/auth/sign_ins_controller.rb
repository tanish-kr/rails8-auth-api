# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SignInsController < ApplicationController
        allow_unauthenticated_access only: %i[create]
        rate_limit to: 10, within: 3.minutes, only: :create

        def create
          user = User.authenticate_by(user_params)

          raise AuthenticationError, "Unauthorized user." unless user

          access_token, refresh_token = start_new_session_for(user)

          render json: { access_token: access_token, refresh_token: refresh_token }, status: :ok
        end

        private

          def user_params
            params.expect(user: %i[email password])
          end
      end
    end
  end
end
