class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
  def authenticate!
    if request.format.json?
      check_token!
    else
      authenticate_user!
    end
  end

  def current_user
    if request.format == Mime[:json]
      @user
    else
      super
    end
  end

  def current_credential
    return nil if request.format != Mime[:json]
    Credential.find_by(key: request.headers["X-API-KEY"]) || Credential.new
  end
  
  private

  def check_token!
    if user = authenticate_with_http_token { |t, _| User.from_token(t) }
      @user = user
    else
      render json: { message: "Not authorized" }, status: 401
    end
  end

  def only_buyers!
    is_buyer = (current_user && current_user.buyer?) && current_credential.buyer?
    render json: {message: "Not authorized"}, status: 401 unless is_buyer
  end

  def set_locale!
    I18n.locale = params[:locale] if params[:locale].present?
  end
end
