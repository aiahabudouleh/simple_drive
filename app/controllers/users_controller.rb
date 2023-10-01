class UsersController < ApplicationController
  before_action :authorize_request, except: :create

    def new
        @user = User.new
      end
    
      def create
        puts "Params received: #{params.inspect}"

        @user = User.new(user_params)
        puts "Params saved: #{params.inspect}"

        # store all emails in lowercase to avoid duplicates and case-sensitive login errors:
        @user.email.downcase!
        
        if @user.save
          # If user saves in the db successfully:
          render json: { message: "Account created successfully!" }, status: :created
        else
          # If user fails model validation - probably a bad password or duplicate email:
          render json: { errors: @user.errors.full_messages, details: @user.errors.to_hash }, status: :unprocessable_entity

        end
      end
    
    private
    
      def user_params
        # strong parameters - whitelist of allowed fields #=> permit(:name, :email, ...)
        # that can be submitted by a form to the user model #=> require(:user)
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
      
    # ----- end of added lines -----
end
