module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def sign_up(_resource_name, _resource)
      # Do not auto-login after sign up.
    end

    def after_sign_up_path_for(_resource)
      new_user_session_path
    end

    def after_inactive_sign_up_path_for(_resource)
      new_user_session_path
    end
  end
end
