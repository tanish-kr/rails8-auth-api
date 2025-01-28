# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Authentication

  class BadParameterError < StandardError; end

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_bad_request
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from BadParameterError, with: :render_bad_request
  rescue_from AuthenticationError, with: :render_unauthorized

  private

    def render_error(title:, status:, details: nil)
      render json: { title:, status:, details: }, status: status
    end

    def render_bad_request(error)
      render_error(title: error.message, status: :bad_request)
    end

    def render_not_found(error)
      render_error(title: error.message, status: :not_found)
    end

    def render_unauthorized(error)
      render_error(title: error.message, status: :unauthorized)
    end

    def render_unprocessable_entity(error)
      render_error(title: error.message, status: :unprocessable_entity)
    end

    def render_internal_server_error(error)
      render_error(title: error.message, status: :internal_server_error)
    end
end
