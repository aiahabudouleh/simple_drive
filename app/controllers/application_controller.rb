class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  before_action :authorize_request, except: [:login, :signup]
  
  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      @decoded = JwtUtil.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render_unauthorized(e.message)
    rescue JWT::DecodeError => e
      render_unauthorized(e.message)
    end
  end

  private

  def render_unauthorized(message)
    render json: { message: "You have to login", details: message }, status: :unauthorized
  end
end
