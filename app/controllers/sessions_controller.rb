require_relative '../../app/util/jwt_util'

class SessionsController < ApplicationController
  before_action :authorize_request, except: :create

  def new
    # No need for anything in here; render the login page.
  end

  def create
    # Look up User in db by the email address submitted to the login form and
    # convert to lowercase to match email in db in case they had caps lock on:
    login_params = params.require(:login).permit(:email, :password)
    user = User.find_by(email: params[:login][:email].downcase)
    
    # Verify user exists in db and run has_secure_password's .authenticate() 
    # method to see if the password submitted on the login form was correct: 
    if user && user.authenticate(params[:login][:password]) 
      # Save the user.id in that user's session cookie:
      token = JwtUtil.encode(user_id: user.id)
      time = Time.now + 24.hours.to_i
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                     email: user.email}, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  def destroy
    # delete the saved user_id key/value from the cookie:
    if session[:user_id].present?
      session.delete(:user_id)
      render json: {
        success: true,
        info: "Logged out successfully.",
      }  
    else 
      render json: {
        success: false,
        info: "No active session found.",
      }, status: :unprocessable_entity
    end    
  end
end
