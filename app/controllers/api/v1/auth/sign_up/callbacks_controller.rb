class Api::V1::Auth::SignUp::CallbacksController < ApplicationController
  allow_unauthenticated_access
  before_action :set_payload

  def show
    raise ActiveRecord::RecordNotFound.new("Payload cannot be read.", self) if @payload[:email].blank?

    render json: { message: "Confirmation token" }, status: :ok
  end

  def create
    raise ActiveRecord::RecordNotFound.new("Payload cannot be read.", self) if @payload[:email].blank?

    @user = User.new(user_params.merge(email: @payload[:email]))

    if @user.save
      render json: { message: "Create User" }, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_payload
    @payload = User.read_confirmation_token(params[:sign_up_token])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
