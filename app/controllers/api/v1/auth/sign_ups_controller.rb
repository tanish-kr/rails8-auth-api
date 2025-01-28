# frozen_string_literal: true

module Api
  module V1
  module Auth
  class SignUpsController < ApplicationController
  allow_unauthenticated_access
  def create
    user = User.new(email: create_params[:email])
    user.validate
    if user.errors[:email].present?
      render json: { message: "Invalid email." }, status: :unprocessable_entity
      return
    end

    AuthMailer.confirmation_email(user).deliver_now
    render json: { message: "Confirmation email sent. Please check your inbox." }, status: :ok
  end

    private

  def create_params
    params.require(:user).permit(:email)
  end
  end
  end
  end
end
