class Api::V1::Auth::SignOutsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :destroy

  def destroy
    terminate_session

    head :no_content
  end
end
