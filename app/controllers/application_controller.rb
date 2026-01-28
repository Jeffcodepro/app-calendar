class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
# teste
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:first_name, :last_name, :role, :email, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(:first_name, :last_name, :role, :email, :password, :password_confirmation, :current_password)
    end
  end

  def set_locale
    I18n.locale = :"pt-BR"
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(_resource_or_scope)
    dashboard_path
  end

  def after_sign_up_path_for(_resource)
    new_user_session_path
  end
end
