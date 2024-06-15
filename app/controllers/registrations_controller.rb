class RegistrationsController < ApplicationController
  skip_forgery_protection only: [:create, :sign_in, :me]
  before_action :authenticate!, only: [:me]
  rescue_from User::InvalidToken, with: :not_authorized

  def create
    @user = User.new(user_params)
    @user.role = current_credential.access

    if @user.save
      render json: { email: @user.email }
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def sign_in
    access = current_credential.access
    user = User.where(role: access).find_by(email: sign_in_params[:email])

    if !user || !user.valid_password?(sign_in_params[:password])
      render json: { message: "Nope!" }, status: 401
    else
      token = User.token_for(user)
      render json: { email: user.email, token: token }
    end
  end

  def me
    render json: { id: current_user.id, email: current_user.email }
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def sign_in_params
    params.require(:login).permit(:email, :password)
  end

  def not_authorized(e)
    render json: { message: "Nope!" }, status: 401
  end
end
