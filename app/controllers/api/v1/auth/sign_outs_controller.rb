# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SignOutsController < ApplicationController
        rate_limit to: 10, within: 3.minutes, only: :destroy

        def destroy
          terminate_session

          head :no_content
        end
      end
    end
  end
end
