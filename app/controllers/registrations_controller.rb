class RegistrationsController < ApplicationController
  skip_forgery_protection only: [:create, :sign_in, :me]
  before_action :authenticate!, only: [:me]

  def create
    @user = User.new(user_params)
    if @user.save
      render json: { email: @user.email }
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def sign_in
    user = User.find_by(email: sign_in_params[:email])
    if user&.valid_password?(sign_in_params[:password])
      token = User.token_for(user)
      render json: { email: user.email, token: token }
    else
      render json: { message: "Nope!" }, status: 401
    end
  end

  def me
    render json: { email: current_user.email, role: current_user.role }
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end

  def sign_in_params
    params.require(:login).permit(:email, :password)
  end
end
